//
//  UserModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/07/2022.
//

import Foundation

class UserModel {

    var id: String?
    var email: String?
    var displayName: String?
    var imageUrl: URL?

    init(user: User, imageUrl: URL?) {
        self.email = user.email
        self.id = user.objectId
        self.displayName = user.displayName
        self.imageUrl = imageUrl
    }
}

extension UserModel: Equatable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id && lhs.email == rhs.email
    }
}
