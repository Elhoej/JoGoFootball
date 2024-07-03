//
//  Empty.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/11/2023.
//

import Foundation

class Empty: Hashable {
    
    let value = "String"
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
    
    static func == (lhs: Empty, rhs: Empty) -> Bool {
        lhs.value == rhs.value
    }
}
