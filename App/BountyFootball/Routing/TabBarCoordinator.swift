//
//  TabBarCoordinator.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import Foundation
import UIKit
import Resolver

protocol TabBarCoordinatorType: CoordinatorType {

}

class TabBarCoordinator: NSObject, TabBarCoordinatorType {

    var baseController: UIViewController? { return self.tabBarController }

    private lazy var tabBarController: UITabBarController = {
        let controller = UITabBarController()

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        controller.tabBar.standardAppearance = appearance
        controller.tabBar.scrollEdgeAppearance = appearance
        controller.tabBar.tintColor = .black
        controller.tabBar.isTranslucent = true
        return controller
    }()
    
    enum TabBarIndex: Int {
        case predict = 0
        case events = 1
    }

    weak var parent: CoordinatorType?
    var childCoordinators: [CoordinatorType] = []

    init(parent: CoordinatorType) {
        self.parent = parent
        super.init()
    }

    func start() throws {

        let predictCoordinator = PredictCoordinator(parent: self)
        try predictCoordinator.start()
        self.childCoordinators.append(predictCoordinator)

        let eventCoordinator = EventCoordinator(parent: self)
        try eventCoordinator.start()
        self.childCoordinators.append(eventCoordinator)

        self.tabBarController.viewControllers = [
            predictCoordinator.baseController,
            eventCoordinator.baseController
        ].compactMap({ $0 })
    }

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }
}

enum TabBarTransition: Transition {
    case predict
    case events
}

enum TabBarIndex: Int {
    case predict = 0
    case rank = 1
}

extension TabBarCoordinator {

    func transition(to transition: Transition) throws {
        if let transition = transition as? TabBarTransition {
            switch transition {
                case .predict:
                    self.tabBarController.selectedIndex = TabBarIndex.predict.rawValue
                case .events:
                    self.tabBarController.selectedIndex = TabBarIndex.events.rawValue
            }
        } else if let transition = transition as? AppTransition {
            switch transition {
                case .route(let route):
                    try? self.transition(to: TabBarTransition.events)
                    try? self.childCoordinators[TabBarIndex.events.rawValue].transition(to: AppTransition.route(route))
                default: try? self.parent?.transition(to: transition)
            }
        }
    }
}
