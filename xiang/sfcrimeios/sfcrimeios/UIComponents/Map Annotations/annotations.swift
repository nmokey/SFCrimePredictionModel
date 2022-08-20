//
//  annotations.swift
//  sfcrimeios
//
//  Created by Alan Xiao on 8/10/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

class CrimeRankAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    var button: UIButton
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var crimeRanking : String 
    @objc dynamic var coordinate : CLLocationCoordinate2D
    
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    
    // This property defined by `MKAnnotation` is not required.
    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, content : String, button: UIButton) {
        self.latitude = latitude
        self.longitude = longitude
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        self.title = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
        self.subtitle = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
        self.button = button
        self.crimeRanking = content
    }
}

func setupCrimeRankAnnotationView(for annotation: CrimeRankAnnotation, on mapView: MKMapView) -> MKAnnotationView {
//    print(annotation.title)
    let reuseIdentifier = NSStringFromClass(CrimeRankAnnotation.self)
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
    
    annotationView.canShowCallout = true
    annotationView.isUserInteractionEnabled = true
    
    let annotationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
    annotationLabel.textAlignment = .center
    annotationLabel.font = UIFont(name: "Arial", size: 10)
    annotationLabel.numberOfLines = 10
    annotationLabel.text = annotation.crimeRanking
    annotationLabel.backgroundColor = UIColor.white
    annotationLabel.adjustsFontSizeToFitWidth = true
    annotationView.addSubview(annotationLabel)
    
//    let infoButton = CrimeRankingPopoverButton(frame: CGRect(x: 0, y: 150, width: 200, height: 75))
//    infoButton.addTarget(viewController, action: #selector(viewController.CrimeRankingPopoverButtonSelector), for: .touchUpInside)
//    print(infoButton.actions(forTarget: viewController, forControlEvent: .touchUpInside))
//    print(infoButton.allTargets)
//    print(infoButton.allControlEvents)
    annotationView.addSubview(annotation.button)
    
    return annotationView
}
