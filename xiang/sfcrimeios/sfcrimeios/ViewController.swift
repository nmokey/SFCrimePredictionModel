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
    // Do any additional setup after loading the view.
    let austin = MKPointAnnotation()
    austin.coordinate = CLLocationCoordinate2DMake(30.25, -97.75)
    austin.title = "Austin"
    mapView.addAnnotation(austin)
    locationManager = CLLocationManager.init()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
    }
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

    struct CrimePredictFeatures: Encodable {
      let Latitude: Float32
      let Longitude: Float32
      let Address: String
      let Dates: String
      let PdDistrict: String
      let DayOfWeek: String
    }
    struct CrimePredictPostData: Encodable {
      let Features: CrimePredictFeatures
    }
    let postData = CrimePredictPostData(Features: CrimePredictFeatures(Latitude: 37.7873589, Longitude: -122.408227, Address: "42042 Indigo Dr", Dates: "2022-08-20 20:15:19", PdDistrict: "SOUTHERN", DayOfWeek: "Wednesday"))
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
      print(predicts.Result.sorted{$0.Prob > $1.Prob}[0])
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("location manager error: \(error)")
  }
}

