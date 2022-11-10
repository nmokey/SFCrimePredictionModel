//
//  CrimePredictionMapAnnotationView.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 11/5/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation
import MapKit

class CrimePredictionMapAnnotationView : MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      guard let crime_prediction = newValue as? CrimePredictionMapAnnotation else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      if let letter = crime_prediction.crimes[0].first {
        glyphText = String(letter)
      }
    }
  }
}
