//
//  SignInViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 15/07/2022.
//

import UIKit
import Combine
import Resolver
import ParseSwift

protocol SignInViewModelType {

    var currentPage: CurrentValueSubject<Int, Never> { get }

    var email: String? { get set }

    var password: String? { get set }

    var displayName: String? { get set }

    var selectedImage: CurrentValueSubject<UIImage?, Never> { get }

    func signUp(user: User, imageData: Data?) -> AnyPublisher<Void, ParseError>

    func signIn(email: String, password: String) -> AnyPublisher<Void, ParseError>

    func resetPassword(email: String) -> AnyPublisher<Void, ParseError>
}

class SignInViewModel: SignInViewModelType {

    var currentPage = CurrentValueSubject<Int, Never>(0)

    var email: String?

    var password: String?

    var displayName: String?

    var selectedImage = CurrentValueSubject<UIImage?, Never>(nil)

    @Injected
    var authService: AuthServiceType

    init() { }

    func signUp(user: User, imageData: Data?) -> AnyPublisher<Void, ParseError> {
        return self.authService.signUp(user: user, imageData: imageData)
    }

    func signIn(email: String, password: String) -> AnyPublisher<Void, ParseError> {
        return self.authService.signIn(email: email, password: password)
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, ParseError> {
        return self.authService.resetPassword(email: email)
    }

    deinit { debugPrint("deinit \(self)") }
}
