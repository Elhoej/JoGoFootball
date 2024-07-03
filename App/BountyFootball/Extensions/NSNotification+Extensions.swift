//
//  NSNotification+Extensions.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation

extension Notification.Name {
    static let refreshEvents = NSNotification.Name(rawValue: "refreshEvents")
    static let refreshMatches = NSNotification.Name(rawValue: "refreshMatches")
}
