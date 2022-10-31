//
//  LocationDataManager.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 10/16/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Contacts
import CoreLocation
import Foundation
import MapKit

import Alamofire

extension Formatter {
  static let mailingAddress: CNPostalAddressFormatter = {
    let formatter = CNPostalAddressFormatter()
    formatter.style = .mailingAddress
    return formatter
  }()
}

extension CLPlacemark {
  var mailingAddress: String? {
    postalAddress?.mailingAddress
  }
}

extension CNPostalAddress {
  var mailingAddress: String {
    Formatter.mailingAddress.string(from: self)
  }
}

extension Date {
  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self).capitalized
  }
}

class LocationDataManager : NSObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  @Published var authorizationStatus: CLAuthorizationStatus?
  weak var mapView: MKMapView?
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  // Location-related properties and delegate methods.
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
    debugPrint("authorization status: ", status)
    switch status {
    case .authorizedWhenInUse:  // Location services are available.
      // Insert code here of what should happen when Location services are authorized
      authorizationStatus = .authorizedWhenInUse
      manager.requestLocation()
      manager.desiredAccuracy = kCLLocationAccuracyBest
      manager.startUpdatingLocation()
      break
    case .restricted:  // Location services currently unavailable.
      // Insert code here of what should happen when Location services are NOT authorized
      authorizationStatus = .restricted
      break
    case .denied:  // Location services currently unavailable.
      // Insert code here of what should happen when Location services are NOT authorized
      authorizationStatus = .denied
      break
    case .notDetermined:        // Authorization not determined yet.
      authorizationStatus = .notDetermined
      manager.requestWhenInUseAuthorization()
      break
    default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("location manager error: \(error)")
  }
  
  func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
      CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: completion)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    print("locations = \(locValue.latitude) \(locValue.longitude)")

    struct CrimePredictFeatures: Encodable {
      let Latitude: Double
      let Longitude: Double
      let Address: String
      let Dates: String
      let DayOfWeek: String
      let PdDistrict: String
    }
    class CrimePredictPostData: Encodable {
      var Features: CrimePredictFeatures
      
      init(Features: CrimePredictFeatures) {
        self.Features = Features
      }
      
      init() {
        self.Features = CrimePredictFeatures(
          Latitude: 0,
          Longitude: 0,
          Address: "",
          Dates: "",
          DayOfWeek: "",
          PdDistrict: ""
        )
      }
    }
    geocode(latitude: locValue.latitude, longitude: locValue.longitude, completion: {
      placemark, error in
        if let error = error as? CLError {
          print("CLError:", error)
          return
        } else if let placemark = placemark?.first {
          //  update UI here
          print("name:", placemark.name ?? "unknown")
          
          print("address1:", placemark.thoroughfare ?? "unknown")
          print("address2:", placemark.subThoroughfare ?? "unknown")
          print("neighborhood:", placemark.subLocality ?? "unknown")
          print("city:", placemark.locality ?? "unknown")
          
          print("state:", placemark.administrativeArea ?? "unknown")
          print("subAdministrativeArea:", placemark.subAdministrativeArea ?? "unknown")
          print("zip code:", placemark.postalCode ?? "unknown")
          print("country:", placemark.country ?? "unknown", terminator: "\n\n")
          
          print("isoCountryCode:", placemark.isoCountryCode ?? "unknown")
          print("region identifier:", placemark.region?.identifier ?? "unknown")
          
          print("timezone:", placemark.timeZone ?? "unknown", terminator:"\n\n")
          // Mailind Address
          print(placemark.mailingAddress ?? "unknown")
          // Get current date time.
          let currentDateTime = Date()
          let RFC3339DateFormatter = DateFormatter()
          RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
          RFC3339DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          RFC3339DateFormatter.timeZone = TimeZone.current
          // Build crime prediction features.
          let features = CrimePredictFeatures(
            Latitude: locValue.latitude,
            Longitude: locValue.longitude,
            Address: placemark.mailingAddress ?? "unknown",
            Dates: RFC3339DateFormatter.string(from: currentDateTime),
            DayOfWeek: currentDateTime.dayOfWeek()!,
            PdDistrict: "SOUTHERN"  // "SOUTHERN" is a dummy value here. Just to make the server not return error.
          )
          print("Reverse geocoding finished!\n")
          let postData = CrimePredictPostData(Features: features)
          debugPrint(postData.Features)
          
          let encoder = JSONEncoder()
          let parameterEncoder = JSONParameterEncoder(encoder: encoder)

          struct CrimeProb: Decodable {
            let Crime: String
            let Prob: Float64
          }
          struct CrimePredictResult: Decodable {
            let Message: String
            let Result: [CrimeProb]
          }
          AF.request("http://13.57.80.134:8000/crime/predict/",
                     method: .post,
                     parameters: postData,
                     encoder: parameterEncoder)
          .responseDecodable(of: CrimePredictResult.self) { (response) in
            guard let predicts = response.value else { return }
            debugPrint(predicts.Message)
            let sorted = predicts.Result.sorted{$0.Prob > $1.Prob}
            let filtered = sorted.filter { $0.Crime != "OTHER OFFENSES"}
            debugPrint(filtered)
            
            // Add map annotation for the top crime.
            var displayCrimes: [String] = []
            var displayProbs: [Double] = []
            // Pick top 3 crimes for display.
            for p in filtered[0...2] {
              displayCrimes.append(p.Crime)
              displayProbs.append(p.Prob)
            }
            let cpAnnotation = CrimePredictionMapAnnotation(
              neighborhood: placemark.name ?? placemark.subLocality ?? placemark.locality ?? "unknown location",
              locationName: features.Address,
              coordinate: locValue,
              crimes: displayCrimes,
              probabilities: displayProbs)
            self.mapView?.removeAnnotations(self.mapView?.annotations ?? [])
            self.mapView?.addAnnotation(cpAnnotation)
            let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate ?? CLLocationCoordinate2D()
            let currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            self.mapView?.centerToLocation(currentLocation)
          }
        }
    })
  }
}
