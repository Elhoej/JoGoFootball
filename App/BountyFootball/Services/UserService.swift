//
//  ProfileService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/07/2022.
//

import UIKit
import ParseSwift
import Combine

protocol UserServiceType {

    var user: CurrentValueSubject<UserModel?, Never> { get }

    var currentUser: User? { get }

    func fetchCurrentUser() -> AnyPublisher<UserModel, ParseError>

    func saveUser(user: User) -> AnyPublisher<Void, ParseError>

    func deleteAvatar() -> AnyPublisher<Void, ParseError>

    func deleteUser() -> AnyPublisher<Void, ParseError>
}

class UserService: UserServiceType {

    var user = CurrentValueSubject<UserModel?, Never>(nil)

    var currentUser: User? { return User.current }

    fileprivate var cancellables: Set<AnyCancellable> = []

    init() {
        self.fetchCurrentUser()
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func fetchCurrentUser() -> AnyPublisher<UserModel, ParseError> {
        guard let currentUser = User.current else {
            return Fail(error: ParseError(code: .objectNotFound, message: ""))
                .eraseToAnyPublisher()
        }

        return currentUser.fetchPublisher()
            .map({ args in
                return UserModel(user: args, imageUrl: args.avatar?.url)
            })
            .handleEvents(receiveOutput: { user in
                self.user.send(user)
            })
            .eraseToAnyPublisher()
    }

    func saveUser(user: User) -> AnyPublisher<Void, ParseError> {
        return user.savePublisher()
            .flatMap({ _ in
                return self.fetchCurrentUser()
            })
            .map({ _ in () })
            .eraseToAnyPublisher()
    }

    func deleteAvatar() -> AnyPublisher<Void, ParseError> {
        guard let user = self.currentUser else {
            return Fail(error: ParseError(code: .objectNotFound, message: ""))
                .eraseToAnyPublisher()
        }

        if let avatar = user.avatar {
            return avatar.deletePublisher()
                .flatMap { _ in
                    return self.fetchCurrentUser()
                }
                .map({ _ in () })
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: ParseError.self)
                .eraseToAnyPublisher()
        }
    }

    func deleteUser() -> AnyPublisher<Void, ParseError> {
        guard let user = self.currentUser else {
            return Fail(error: ParseError(code: .objectNotFound, message: ""))
                .eraseToAnyPublisher()
        }
        return user.deletePublisher().flatMap { _ in
            return User.logoutPublisher()
        }
        .eraseToAnyPublisher()
    }
}
