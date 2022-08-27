//
//  ViewController.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 10/24/21.
//  Copyright © 2021 Xiang Xiao. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import Alamofire

class ViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  var locationManager:CLLocationManager!
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
    }
  }

}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

import Contacts

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

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_
    manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse:
      print("Authorized When in Use")
    case .authorizedAlways:
      print("Authorized Always")
    case .denied:
      print("Denied")
    case .notDetermined:
      print("Not determined")
    case .restricted:
      print("Restricted")
    @unknown default:
      print("Unknown status")
    }
  }
  
  func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
      CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: completion)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    print("locations = \(locValue.latitude) \(locValue.longitude)")
    let currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    mapView.centerToLocation(currentLocation)

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
          AF.request("http://127.0.0.1:8000/crime/predict/",
                     method: .post,
                     parameters: postData,
                     encoder: parameterEncoder)
          .responseDecodable(of: CrimePredictResult.self) { (response) in
            debugPrint(response)
            guard let predicts = response.value else { return }
            print(predicts.Message)
            let topPrediction = predicts.Result.sorted{$0.Prob > $1.Prob}[0]
            print(topPrediction)
            
            // Add map annotation for the top crime.
            let cpAnnotation = CrimePredictionMapAnnotation(
              title: placemark.subLocality ?? "unknown",
              locationName: features.Address,
              coordinate: locValue,
              crimes: [topPrediction.Crime],
              probabilities: [topPrediction.Prob])
            self.mapView.addAnnotation(cpAnnotation)
          }
        }
    })
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("location manager error: \(error)")
  }
}

