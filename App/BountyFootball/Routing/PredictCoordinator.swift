//
//  PredictCoordinator.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import UIKit
import Resolver

protocol PredictCoordinatorType: CoordinatorType { }

extension PredictCoordinatorType { }

class PredictCoordinator: NSObject, PredictCoordinatorType {

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
        let controller = PredictViewController()
        controller.tabBarItem.image = Media.tabPredictInactive.image
        controller.tabBarItem.selectedImage = Media.tabPredictActive.image
        controller.tabBarItem.title = "Predict"
        controller.coordinator = self
        self.navigationController.setViewControllers([controller], animated: false)
    }

    func route(to route: Route) { }

    deinit { debugPrint("deinit \(self)") }
}

enum PredictTransition: Transition {
    case settings
    case detail(MatchContainerModel, TeamPrediction? = nil)
    case filter(presenter: ChooseLeagueViewControllerDelegate)
}

extension PredictCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? PredictTransition {
            switch transition {
                case .settings:
                    let coordinator = SettingsCoordinator(parent: self)
                    try! coordinator.start()
                    self.navigationController.present(coordinator.baseController!, animated: true)
                case .detail(let match, let selectedPrediction):
                    Resolver.register(name: .match) { match }
                    Resolver.register(name: .preSelectedPrediction) { selectedPrediction }
                    let controller = PredictDetailViewController()
                    controller.coordinator = self
                    self.navigationController.present(controller, animated: true)
                case .filter(let presenter):
                    Resolver.register(name: .preselectLeagues) { true }
                    let controller = ChooseLeagueViewController()
                    controller.coordinator = self
                    controller.delegate = presenter
                    controller.titleLabel.text = "Filter"
                    self.navigationController.present(controller, animated: true)
            }
        } else if let transition = transition as? AppTransition {
            try? self.parentCoordinator?.transition(to: transition)
        }
    }
}
