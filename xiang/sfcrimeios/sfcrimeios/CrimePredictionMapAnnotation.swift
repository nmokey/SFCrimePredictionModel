//
//  CrimePredictionMapAnnotation.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 8/27/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation

import MapKit

class CrimePredictionMapAnnotation: NSObject, MKAnnotation {
  let title: String?
  let locationName: String?
  var coordinate: CLLocationCoordinate2D
    
  let crimes: [String]
  let probabilities: [Double]

  init(
    title: String?,
    locationName: String?,
    coordinate: CLLocationCoordinate2D,
    crimes: [String],
    probabilities: [Double]
  ) {
    self.title = title
    self.locationName = locationName
    self.coordinate = coordinate
    self.crimes = crimes
    self.probabilities = probabilities

    super.init()
  }

  var subtitle: String? {
      var display = ""
      for (crime, prob) in zip(crimes, probabilities) {
          display += crime + ":" + String(format: "%2.0f", prob*100) + "%\n"
      }
      return display
  }
}
