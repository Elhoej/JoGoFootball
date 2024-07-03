//
//  Collection+Extensions.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import Foundation

public extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
