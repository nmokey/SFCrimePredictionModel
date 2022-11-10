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
  
  var locationDataManager: LocationDataManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationDataManager = LocationDataManager()
    let locValue: CLLocationCoordinate2D = locationDataManager.locationManager.location?.coordinate ?? CLLocationCoordinate2D()
    let currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    mapView.centerToLocation(currentLocation)
    locationDataManager.mapView = mapView
    mapView.register(
      CrimePredictionMapAnnotationView.self,
      forAnnotationViewWithReuseIdentifier:
        MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.delegate = self
  }
}

extension MKMapView {
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

extension ViewController: MKMapViewDelegate {
}
