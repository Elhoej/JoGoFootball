//
//  SignInCoordinator.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/07/2022.
//

import UIKit
//import Resolver

protocol SignInCoordinatorType: CoordinatorType { }

extension SignInCoordinatorType { }

class SignInCoordinator: NSObject, SignInCoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    fileprivate weak var parentCoordinator: CoordinatorType?

    fileprivate lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()

    init(parent: CoordinatorType) {
        self.parentCoordinator = parent
        super.init()
    }

    init(parent: CoordinatorType, navController: UINavigationController) {
        self.parentCoordinator = parent
        super.init()
        self.navigationController = navController
    }

    func start() throws {
        let controller = WelcomeViewController()
        controller.coordinator = self
        self.navigationController.setViewControllers([controller], animated: false)
    }

    func route(to route: Route) { }

    deinit { debugPrint("deinit \(self)") }
}

enum SignInTransition: Transition {
    case signUp
    case signIn
    case forgotPassword
}

extension SignInCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? SignInTransition {
            switch transition {
                case .signUp:
                    let controller = SignUpViewController()
                    controller.coordinator = self
                    self.navigationController.pushViewController(controller, animated: true)
                case .signIn:
                    let controller = SignInViewController()
                    controller.coordinator = self
                    self.navigationController.pushViewController(controller, animated: true)
                case .forgotPassword:
                    let controller = ForgotPasswordViewController()
                    self.navigationController.pushViewController(controller, animated: true)
            }
        } else if let transition = transition as? AppTransition {
            try? self.parentCoordinator?.transition(to: transition)
        }
    }
}
