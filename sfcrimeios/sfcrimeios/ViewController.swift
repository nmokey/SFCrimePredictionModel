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
//  var locationManager:CLLocationManager!
  var locationDataManager: LocationDataManager!
  override func viewDidLoad() {
    super.viewDidLoad()
//    locationManager = CLLocationManager.init()
//    locationManager.delegate = self
//    locationManager.requestWhenInUseAuthorization()
//    if CLLocationManager.locationServicesEnabled() {
//      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//      locationManager.startUpdatingLocation()
//    }
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

