import UIKit
import MapKit

//creating ViewController class
class ViewController: UIViewController {
  //creates outlet from Interface Builder to view controller through @IBOutlet (hence black circle)
  @IBOutlet private var mapView: MKMapView!
  
  private var artworks: [Artwork] = []
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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    //calls method to zoom into initialLocation (defined in line 21)
    mapView.centerToLocation(initialLocation)
    
    //sets constraints on how far the camera can zoom out and pan to
    let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
    let region = MKCoordinateRegion(
      center: oahuCenter.coordinate,
      latitudinalMeters: 50000,
      longitudinalMeters: 60000)
    mapView.setCameraBoundary(
      MKMapView.CameraBoundary(coordinateRegion: region),
      animated: true)
    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    mapView.setCameraZoomRange(zoomRange, animated: true)
    
    mapView.delegate = self
    
    // Show artwork King statue on map using the class Artwork we created in artwork.Swift
    let artwork = Artwork(
      title: "King David Kalakaua",
      locationName: "Waikiki Gateway Park",
      discipline: "Sculpture",
      coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
    mapView.addAnnotation(artwork)
    mapView.register(
      ArtworkView.self,
      forAnnotationViewWithReuseIdentifier:
        MKMapViewDefaultAnnotationViewReuseIdentifier)

    loadInitialData()
    mapView.addAnnotations(artworks)
    
    
  }
}

//private extension of MapView that specifies what region of the map to center on and at what zoom level
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

//Configuring the annotation view and how it appears on the map (extension of ViewController)
extension ViewController: MKMapViewDelegate {
  // 1
//  func mapView(
//    _ mapView: MKMapView,
//    viewFor annotation: MKAnnotation
//  ) -> MKAnnotationView? {
//    // 2 - checking if the annotation is an Artwork object. If not, returns nil
//    guard let annotation = annotation as? Artwork else {
//      return nil
//    }
//    // 3 - make each view as an annotation (MKMarkerAnnotationView)
//    let identifier = "artwork"
//    var view: MKMarkerAnnotationView
//    // 4  -
//    if let dequeuedView = mapView.dequeueReusableAnnotationView(
//      withIdentifier: identifier) as? MKMarkerAnnotationView {
//      dequeuedView.annotation = annotation
//      view = dequeuedView
//    } else {
//      // 5
//      view = MKMarkerAnnotationView(
//        annotation: annotation,
//        reuseIdentifier: identifier)
//      view.canShowCallout = true
//      view.calloutOffset = CGPoint(x: -5, y: 5)
//      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//    }
//    return view
//  }
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let artwork = view.annotation as? Artwork else {
      return
    }

    let launchOptions = [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ]
    artwork.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}
