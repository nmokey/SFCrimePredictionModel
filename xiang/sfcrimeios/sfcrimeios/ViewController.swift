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
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("location manager error: \(error)")
  }
}

