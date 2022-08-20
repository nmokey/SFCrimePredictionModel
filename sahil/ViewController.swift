/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  @IBOutlet private var mapView: MKMapView!
  private var artworks: [Artwork] = []
  var locationManager:CLLocationManager!
      var currentLocationStr = "Current location"
  var initialLatitude: Double = 0.0
  var initialLongitude: Double = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getUserLocation()
    // Set initial location in Honolulu
    let initialLocation = CLLocation(latitude: initialLatitude, longitude: initialLongitude)
    mapView.centerToLocation(initialLocation)
    
    let oahuCenter = CLLocation(latitude: initialLatitude, longitude: initialLongitude)
    let region = MKCoordinateRegion(
      center: oahuCenter.coordinate,
      latitudinalMeters: 20000,
      longitudinalMeters: 20000)
    mapView.setCameraBoundary(
      MKMapView.CameraBoundary(coordinateRegion: region),
      animated: true)
    
    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    mapView.setCameraZoomRange(zoomRange, animated: true)
    
    mapView.delegate = self
    
    mapView.register(
      ArtworkView.self,
      forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    
    loadInitialData()
    mapView.addAnnotations(artworks)
  }
  
  func getUserLocation() {
    locationManager = CLLocationManager()
    locationManager?.requestAlwaysAuthorization()
    locationManager?.startUpdatingLocation()
    locationManager?.delegate = self
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          let mUserLocation:CLLocation = locations[0] as CLLocation

          let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
          let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
              mapView.setRegion(mRegion, animated: true)
    if let location = locations.last {
      print("Lat : \(location.coordinate.latitude) \nLng : \(location.coordinate.longitude)")
      initialLatitude = location.coordinate.latitude
      initialLongitude = location.coordinate.longitude
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Error - locationManager: \(error.localizedDescription)")
      }
  //MARK:- Intance Methods

  
  private func loadInitialData() {
    // 1
    guard
      let fileName = Bundle.main.url(forResource: "PublicArt", withExtension: "geojson"),
      let artworkData = try? Data(contentsOf: fileName)
      else {
        return
    }
    
    do {
      // 2
      let features = try MKGeoJSONDecoder()
        .decode(artworkData)
        .compactMap { $0 as? MKGeoJSONFeature }
      // 3
      let validWorks = features.compactMap(Artwork.init)
      // 4
      artworks.append(contentsOf: validWorks)
    } catch {
      // 5
      print("Unexpected error: \(error).")
    }
  }
}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension ViewController {
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let artwork = view.annotation as? Artwork else {
      return
    }
    
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    artwork.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}
