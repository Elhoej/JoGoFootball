//
//  SettingsViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 20/07/2022.
//

import UIKit
import Resolver
import Combine
import ParseSwift

protocol SettingsViewModelType {

    var user: CurrentValueSubject<UserModel?, Never> { get }

    func saveUser(user: User) -> AnyPublisher<Void, ParseError>

    func deleteAvatar() -> AnyPublisher<Void, ParseError>

    func deleteUser() -> AnyPublisher<Void, ParseError>
}

class SettingsViewModel: SettingsViewModelType {

    @Injected
    var userService: UserServiceType

    var user: CurrentValueSubject<UserModel?, Never> {
        return self.userService.user
    }

    func saveUser(user: User) -> AnyPublisher<Void, ParseError> {
        return self.userService.saveUser(user: user)
    }

    func deleteAvatar() -> AnyPublisher<Void, ParseError> {
        return self.userService.deleteAvatar()
    }

    func deleteUser() -> AnyPublisher<Void, ParseError> {
        return self.userService.deleteUser()
    }

}
