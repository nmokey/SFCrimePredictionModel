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
  
  @IBOutlet weak var tableView: UITableView!
  
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
    mapView.showsUserLocation = true
    
    locationDataManager.tableView = tableView
    tableView.dataSource = self
    tableView.delegate = self
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

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if ((locationDataManager.crimePredictionResult) != nil) {
      debugPrint(locationDataManager.crimePredictionResult!.Result.count)
      return min(locationDataManager.crimePredictionResult!.Result.count, 3)
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CrimeProbTableViewCell", for: indexPath)
    let crimeProb = locationDataManager.crimePredictionResult?.Result[indexPath.row]
    debugPrint("\(crimeProb!.Crime) for table view row \(indexPath.row)")
    cell.textLabel?.text = crimeProb?.Crime
    cell.detailTextLabel?.text = String(format: "%2.0f", crimeProb!.Prob*100) + "%"
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120/CGFloat(tableView.numberOfRows(inSection: 0))
  }
}

extension ViewController: UITableViewDelegate {
}
