//
//  crimeRankTableView.swift
//  sfcrimeios
//
//  Created by Alan Xiao on 8/9/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation
import SwiftUI

struct crimeRankTableView : View {
  @State var showingPopover = false
  @State var crimeRankDict : Dictionary<String, Double>

  var body: some View {
    Button(action: {
      self.showingPopover = true
    }) {
      Text("Show new view")
    }.popover(isPresented: $showingPopover){
      HStack {
        Text("New Popover")
      }.frame(width: 500, height: 500)
        .background(Color.red)
    }
  }
}
