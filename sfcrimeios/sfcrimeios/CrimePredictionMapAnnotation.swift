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
  let neighborhood: String
  let locationName: String
  var coordinate: CLLocationCoordinate2D
    
  let crimes: [String]
  let probabilities: [Double]

  init(
    neighborhood: String,
    locationName: String,
    coordinate: CLLocationCoordinate2D,
    crimes: [String],
    probabilities: [Double]
  ) {
    self.neighborhood = neighborhood
    self.locationName = locationName
    self.coordinate = coordinate
    self.crimes = crimes
    self.probabilities = probabilities

    super.init()
  }

  var title: String? {
    var display = neighborhood + "\n"
    display += crimes[0] + ":" + String(format: "%2.0f", probabilities[0]*100) + "%\n"
    return display
  }
  
  var subtitle: String? {
    var display = ""
    var i = 0
    for (crime, prob) in zip(crimes, probabilities) {
      i += 1
      if (i == 1) { continue }
      display += crime + ":" + String(format: "%2.0f", prob*100) + "%\n"
    }
    return display
  }
}
