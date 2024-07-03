//
//  LeagueModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/08/2023.
//

import Foundation
import ParseSwift

struct LeagueModel: ParseObject {
    
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var name: String?
    var leagueId: Int?
    var logo: ParseFile?
    var active: Bool?
    var priority: Int?
    var country: String?
    
    static var className: String {
        return "League"
    }
}
