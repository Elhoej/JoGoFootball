//
//  SettingsCoordinator.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 20/07/2022.
//

import UIKit
//import Resolver

protocol SettingsCoordinatorType: CoordinatorType { }

extension SettingsCoordinatorType { }

class SettingsCoordinator: NSObject, SettingsCoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    fileprivate weak var parentCoordinator: CoordinatorType?

    fileprivate lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
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
        let controller = SettingsViewController()
        controller.coordinator = self
        self.navigationController.setViewControllers([controller], animated: false)
    }

    func route(to route: Route) { }

    deinit { debugPrint("deinit \(self)") }
}

enum SettingsTransition: Transition {
    case profile
}

extension SettingsCoordinator {

    func transition(to transition: Transition) throws {
        if let transition = transition as? SettingsTransition {
            switch transition {
                case .profile:
                    let controller = ProfileViewController()
                    controller.coordinator = self
                    self.navigationController.pushViewController(controller, animated: true)
            }
        } else if let transition = transition as? AppTransition {
            try? self.parentCoordinator?.transition(to: transition)
        }
    }
}
