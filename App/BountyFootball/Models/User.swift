//
//  User.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 15/07/2022.
//

import Foundation
import ParseSwift

struct User: ParseUser {

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.username == rhs.username && lhs.displayName == rhs.displayName
    }

    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String : [String : String]?]?
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    var displayName: String?
    var avatar: ParseFile?
}

extension User {
    var isCurrentUser: Bool {
        return self == User.current
    }
}
