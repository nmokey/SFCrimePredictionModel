//
//  CrimePredictionMapAnnotationView.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 11/5/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation
import MapKit

extension NSAttributedString {
  convenience init(htmlString html: String) throws {
    try self.init(data: Data(html.utf8), options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ], documentAttributes: nil)
  }
}

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

      let detailLabel = UILabel()
      detailLabel.numberOfLines = 0
      detailLabel.font = detailLabel.font.withSize(12)
      detailLabel.attributedText = try? NSAttributedString(htmlString: crime_prediction.detailHtml)
      detailCalloutAccessoryView = detailLabel
    }
  }
}
