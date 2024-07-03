//
//  EventModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import ParseSwift

struct EventModel: ParseObject {
    
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var name: String?
    var startTimestamp: Int?
    var endTimestamp: Int?
    var eventImage: ParseFile?
    var eventType: EventType?
    var inviteCode: String?
    var finished: Bool?
    
    var users: ParseRelation<Self>?
    var leagues: ParseRelation<Self>?
    
    static var className: String {
        return "Event"
    }
}

extension EventModel: Comparable {
    static func < (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.endTimestamp ?? 0 > rhs.endTimestamp ?? 0
    }
}

enum EventType: String, Codable {
    case open = "OPEN"
    case `private` = "PRIVATE"
    case global = "GLOBAL"
}
