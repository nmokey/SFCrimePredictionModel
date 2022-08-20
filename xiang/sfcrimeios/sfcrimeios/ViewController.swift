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
import SwiftUI

class CrimePredictionResponse: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }
    
    var Message: String
    var Result: Dictionary<String, Double>
    
    init(M: String, R: Dictionary<String, Double>) {
        Message = M
        Result = R
    }
    
    init() {
        Message = ""
        Result = [:]
    }
}

class CrimePredictionRawDataPoint: Codable {
    enum Category: String, Codable {
        case swift, combine, debugging, xcode
    }
    
    init(Latitude : CLLocationDegrees,
         Longitude: CLLocationDegrees,
         PdDistrict : String,
         Address : String,
         DayOfWeek: String,
         Dates: String
        ) {
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.PdDistrict = PdDistrict
        self.Address = Address
        self.DayOfWeek = DayOfWeek
        self.Dates = Dates
    }
    
    let Latitude : CLLocationDegrees
    let Longitude: CLLocationDegrees
    let PdDistrict : String
    let Address: String
    let DayOfWeek: String
    let Dates: String
}

func getCurrentDatetime() -> String {
    let date = Date()
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = format.string(from: date)
    return timestamp
}

func checkIfClientInSF(placemark: CLPlacemark) -> Bool {
//    print(placemark)
    return (placemark.subAdministrativeArea == "San Francisco County" ||
            placemark.locality == "San Francisco")
}


func sendCrimePredictionRequest(locValue: CLLocationCoordinate2D, finished: @escaping (CrimePredictionResponse, String) -> Void) {
    let url = URL(string: "http://192.168.0.101:8000/crime/predict/")! //change the url
            
       //create the session object
       let session = URLSession.shared
            
       //now create the URLRequest object using the url object
       var request = URLRequest(url: url)
      request.httpMethod = "POST"
          
    let request_features = CrimePredictionRawDataPoint(
       Latitude: locValue.latitude,
       Longitude: locValue.longitude,
       PdDistrict: "SOUTHERN",
       Address: "42042 Indigo Dr",
       DayOfWeek: "Wednesday",
       Dates: getCurrentDatetime()
    )
    
//    var finalRes = CrimePredictionResponse(M: "ERROR", R: [:])
    
    //Encoding object first to JSON string, then Data object
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let encoded_features = try! encoder.encode(["Features": request_features])
    //JSON string
    let body = String(data: encoded_features, encoding: .utf8)!
//    print(body)
    
    //Data object
    let bodyData = body.data(using: .utf8)!
    
    request.httpBody = bodyData
  
    let task = session.dataTask(with: request) { (data, response, error) in
        guard error  == nil else {
            let error_msg = "error encountered:\n \(String(describing: error))"
            finished(CrimePredictionResponse(), error_msg)
            return
        }
        
        guard let jsonData = data else {
            let error_msg = "No response data"
            finished(CrimePredictionResponse(), error_msg)
            return
        }
        
        let res = try? JSONDecoder().decode(CrimePredictionResponse.self, from: jsonData)
        
        if let decodedRes = res {
            finished(decodedRes, "")
        } else {
            print("Response not able to be decoded.")
            return
        }
      }

       task.resume()
}

extension CLLocation {
    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                handler(firstLocation)
            } else {
                handler(nil)
                print("There was an error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  var locationManager:CLLocationManager!
    var button = CrimeRankingPopoverButton(frame: CGRect(x: 0, y: 150, width: 200, height: 200))
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    locationManager = CLLocationManager.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    }
      mapView.delegate = self
      registerMapAnnotationViews()
      button.addTarget(self, action: #selector(CrimeRankingPopoverButtonSelector), for: .touchUpInside)
  }
    
    @objc func CrimeRankingPopoverButtonSelector(sender: UIButton, forEvent event: UIEvent) {
        print(event) 
    }
    
    private func registerMapAnnotationViews() {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CrimeRankAnnotation.self))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? CrimeRankAnnotation {
            annotationView = setupCrimeRankAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? MKPointAnnotation {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: NSStringFromClass(MKPointAnnotation.self))
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Button Tapped!")
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

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    print("locations = \(locValue.latitude) \(locValue.longitude)")
      
      let loc = CLLocation.init(latitude: locValue.latitude, longitude: locValue.longitude)
      var ok = true
      loc.lookUpPlaceMark() { (placemark) in
          if placemark == nil {
            ok = false
          } else {
            ok = checkIfClientInSF(placemark: placemark!)
          }
      }
      
      if ok == false {
          print("Error: Client not in San Francisco")
          return
      }
      
      sendCrimePredictionRequest(locValue: locValue) { (CPResponse, error_) in
          if error_ != "" {
              print(error_)
          } else {
              DispatchQueue.main.async {
                var content = ""
                  let sortedRes = CPResponse.Result.sorted { (x, y) -> Bool in
                      return x.value > y.value
                  }
                
                var cnt = 0
                for (cat, pred) in sortedRes {
                    content += cat + ": " + String(format: "%f", pred) + "\n"
                    cnt += 1
                    if cnt == 10 {
                        break
                    }
                }
          
                print(content)
          
                self.addPredictionAnnotation(to: loc, with: content)
              }
          }
      }
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("location manager error: \(error)")
  }
    
    func addPredictionAnnotation(to location: CLLocation, with content: String) {
        let SFAnnotation = CrimeRankAnnotation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, content: content, button: self.button)
        self.mapView.addAnnotation(SFAnnotation)
        
        self.mapView.setRegion(MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 100,
            longitudinalMeters: 100
        ), animated: true)
    }
}
