//
//  CrimePrediction.swift
//  sfcrimeios
//
//  Created by Xiang Xiao on 11/13/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation

struct CrimeProb: Decodable {
  let Crime: String
  let Prob: Float64
}

class CrimePredictionResult: Decodable {
  var Message: String
  var Result: [CrimeProb]
  
  init(_ message: String, _ crimProbs: [CrimeProb]) {
    self.Message = message
    self.Result = crimProbs
  }
}
