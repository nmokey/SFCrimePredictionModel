//
//  CrimeRankPopoverButton.swift
//  sfcrimeios
//
//  Created by Alan Xiao on 8/11/22.
//  Copyright © 2022 Xiang Xiao. All rights reserved.
//

import Foundation
import SwiftUI

class CrimeRankingPopoverButton: UIButton {
    required init?(coder: NSCoder) {
        fatalError("code not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.setTitle("Info Button", for: .normal)
        self.backgroundColor = .white
        self.setTitleColor(.cyan, for: .normal)
    }
}
