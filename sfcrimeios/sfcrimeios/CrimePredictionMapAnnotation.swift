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

  var detailHtml: String {
    var html = "<h2>" + neighborhood + "</h2><table>"
    html += "<th>Crime</th><th>Prob</th>"
    for (crime, prob) in zip(crimes, probabilities) {
      html += "<tr><td>" + crime + "</td><td>" + String(format: "%2.0f", prob*100) + "%</td></tr>"
    }
    html += "</table>"
    return html
  }
}
