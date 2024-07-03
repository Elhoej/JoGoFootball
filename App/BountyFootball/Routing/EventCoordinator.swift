//
//  RankCoordinator.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import UIKit
import Resolver
import Combine

protocol EventCoordinatorType: CoordinatorType { }

extension EventCoordinatorType { }

class EventCoordinator: NSObject, EventCoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    fileprivate weak var parentCoordinator: CoordinatorType?

    fileprivate lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()
    
    @Injected
    var eventService: EventServiceType
    var cancellables: Set<AnyCancellable> = []

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
        let controller = EventsViewController()
        controller.tabBarItem.image = Media.tabEventsInactive.image
        controller.tabBarItem.selectedImage = Media.tabEventsActive.image
        controller.tabBarItem.title = "Events"
        controller.coordinator = self
        self.navigationController.setViewControllers([controller], animated: false)
    }

    func route(to route: Route) { }

    deinit { debugPrint("deinit \(self)") }
}

enum EventTransition: Transition {
    case settings
    case join(JoinEventViewControllerDelegate)
    case create
    case chooseCompetitions(presenter: ChooseLeagueViewControllerDelegate)
    case chooseDuration(presenter: EventDurationViewControllerDelegate)
    case detail(EventModel)
    case user(EventRankModel)
    case invite
}

extension EventCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? EventTransition {
            switch transition {
                case .settings:
                    let coordinator = SettingsCoordinator(parent: self)
                    try! coordinator.start()
                    self.navigationController.present(coordinator.baseController!, animated: true)
                case .join(let delegate):
                    let controller = JoinEventViewController()
                    controller.delegate = delegate
                    self.navigationController.present(controller, animated: true)
                case .create:
                    let controller = CreateEventViewController()
                    controller.coordinator = self
                    self.navigationController.present(controller, animated: true)
                case .chooseCompetitions(let presenter):
                    Resolver.register(name: .preselectLeagues) { false }
                    let controller = ChooseLeagueViewController()
                    controller.coordinator = self
                    controller.delegate = presenter
                    controller.titleLabel.text = "Valid competitions"
                    self.navigationController.presentedViewController?.present(controller, animated: true)
                case .chooseDuration(presenter: let presenter):
                    let controller = EventDurationViewController()
                    controller.coordinator = self
                    controller.delegate = presenter
                    self.navigationController.presentedViewController?.present(controller, animated: true)
                case .detail(let event):
                    Resolver.register(name: .event) { event }
                    let controller = EventDetailViewController()
                    controller.coordinator = self
//                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController.pushViewController(controller, animated: true)
                case .user(let rankModel):
                    Resolver.register(name: .rankModel) { rankModel }
                    let controller = UserDetailViewController()
                    controller.coordinator = self
                    self.navigationController.present(controller, animated: true)
                case .invite:
                    let controller = InviteEventViewController()
                    self.navigationController.present(controller, animated: true)
            }
        } else if let transition = transition as? AppTransition {
            switch transition {
                case .route(let route):
                    switch route {
                        case .joinEvent(let invitationCode):
                            self.eventService.joinEvent(with: invitationCode)
                                .sink { _ in } receiveValue: { event in
                                    NotificationCenter.default.post(name: .refreshEvents, object: self)
                                    if let controller = self.navigationController.viewControllers.first as? EventsViewController {
                                        controller.didJoin(event: event)
                                    }
                                }
                                .store(in: &self.cancellables)
                    }
                default: try? self.parentCoordinator?.transition(to: transition)
            }
        }
    }
}
