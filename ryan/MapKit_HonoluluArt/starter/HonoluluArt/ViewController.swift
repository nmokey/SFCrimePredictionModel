import UIKit
import MapKit

class ViewController: UIViewController {
  @IBOutlet private var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    mapView.centerToLocation(initialLocation)

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
