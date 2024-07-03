//
//  AuthService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/07/2022.
//

import Foundation
import ParseSwift
import Combine

protocol AuthServiceType {

    func signUp(user: User, imageData: Data?) -> AnyPublisher<Void, ParseError>

    func signIn(email: String, password: String) -> AnyPublisher<Void, ParseError>

    func signOut() -> AnyPublisher<Void, ParseError>
    
    func resetPassword(email: String) -> AnyPublisher<Void, ParseError>
    
}

class AuthService: AuthServiceType {

    func signUp(user: User, imageData: Data?) -> AnyPublisher<Void, ParseError> {
        return user.signupPublisher()
            .flatMap({ user -> AnyPublisher<User, ParseError> in
                if let data = imageData {
                    var user = user
                    let imageFile = ParseFile(name: "\(user.id)-avatar", data: data)
                    user.avatar = imageFile
                    return user.savePublisher()
                        .eraseToAnyPublisher()
                } else {
                    return Just(user)
                        .setFailureType(to: ParseError.self)
                        .eraseToAnyPublisher()
                }
            })
            .flatMap({ user -> AnyPublisher<User, ParseError> in
                if var installation = InstallationModel.current {
                    installation.userId = user.objectId
                    return installation.savePublisher()
                        .map({ _ in return user })
                        .eraseToAnyPublisher()
                } else {
                    return Just(user)
                        .setFailureType(to: ParseError.self)
                        .eraseToAnyPublisher()
                }
            })
            .map({ _ in () })
            .eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<Void, ParseError> {
        return User.loginPublisher(username: email, password: password, options: [])
            .flatMap({ user in
                if var installation = InstallationModel.current {
                    installation.userId = user.objectId
                    return installation.savePublisher()
                        .map({ _ in return user })
                        .eraseToAnyPublisher()
                } else {
                    return Just(user)
                        .setFailureType(to: ParseError.self)
                        .eraseToAnyPublisher()
                }
            })
            .map({ _ in () })
            .eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Void, ParseError> {
        return User.logoutPublisher()
            .eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, ParseError> {
        return User.passwordResetPublisher(email: email)
            .eraseToAnyPublisher()
    }
}
