import UIKit
import Resolver
import ParseSwift

protocol AppCoordinatorType: CoordinatorType {

    init(window: UIWindow)

//    func received(deviceToken: Data)
//
//    func failedToRegister(error: Error)
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

final class AppCoordinator: NSObject {

    weak var window: UIWindow?

    var baseController: UIViewController? { return self.navigationController }
    fileprivate lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()

    var childCoordinators: [CoordinatorType] = []
    var tabBarCoordinator: CoordinatorType?

    required init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() throws {
        if let user = User.current {
            try? self.transition(to: AppTransition.signedIn)
        } else {
            try? self.transition(to: AppTransition.signedOut)
        }

        self.window?.makeKeyAndVisible()
    }

//    func startOnboarding() {
//        let coordinator = SignInCoordinator(parent: self)
//        try! coordinator.start()
//        self.window?.rootViewController = coordinator.baseController!
//    }
//
//    func startApp(user: User) {
//        Resolver.register { user }
//        let coordinator = HangoutsCoordinator(parent: self)
//        try! coordinator.start()
//        self.window?.rootViewController = coordinator.baseController!
//        self.authorizeRemoteNotifications()
//    }

//    func authorizeRemoteNotifications() {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.authorizationStatus == .notDetermined {
//                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { authorized, error in
//                    if authorized {
//                        DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
//                    }
//                }
//            } else if settings.authorizationStatus == .authorized {
//                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
//            }
//        }
//    }

//    func received(deviceToken: Data) {
//        print("received token")
//        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
//        print(deviceTokenString)
//    }
//
//    func failedToRegister(error: Error) {
//        print(error)
//    }

    func stop() throws { }

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }
}

extension AppCoordinator: AppCoordinatorType {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
        
        let path = components.path
        let params = components.queryItems
        
        if path.contains("invitation"), let invitationCode = params?.first(where: { $0.name == "code" })?.value {
            let route = AppRoute.joinEvent(invitationCode)
            try? self.transition(to: AppTransition.route(route))
            return true
        }
        return false
    }
}

//extension AppCoordinator: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let currentUserId = Auth.auth().currentUser?.uid, let pushToken = fcmToken else { return }
//        Firestore.firestore().collection(.users).document(currentUserId).setData(["pushToken": pushToken], merge: true, completion: nil)
//    }
//}

//extension AppCoordinator: UNUserNotificationCenterDelegate {
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.list, .banner, .badge, .sound])
//    }
//}

enum AppTransition: Transition {
    case signedIn
    case signedOut
    case route(AppRoute)
}

enum AppRoute: Route {
    case joinEvent(String)
}

extension AppCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? AppTransition {
            switch transition {
                case .signedIn:
                    let tabBarCoordinator = TabBarCoordinator(parent: self)
                    try? tabBarCoordinator.start()
                    self.childCoordinators.append(tabBarCoordinator)
                    self.tabBarCoordinator = tabBarCoordinator
                    self.window?.rootViewController = tabBarCoordinator.baseController!
                case .signedOut:
                    let signInCoordinator = SignInCoordinator(parent: self)
                    try? signInCoordinator.start()
                    self.window?.rootViewController = signInCoordinator.baseController!
                case .route(let route):
                    switch route {
                        case .joinEvent:
                            try? self.tabBarCoordinator?.transition(to: AppTransition.route(route))
                    }
            }
        }
    }
}

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {

        //* ---------- VIEWMODELS ---------- *//
        self.register(SignInViewModelType.self) { SignInViewModel() }.scope(.shared)
        self.register(PredictViewModelType.self) { PredictViewModel() }
        self.register(PredictDetailViewModelType.self) { PredictDetailViewModel() }.scope(.shared)
        self.register(SettingsViewModelType.self) { SettingsViewModel() }
        self.register(EventsViewModelType.self) { EventsViewModel() }
        self.register(LeagueViewModelType.self) { LeagueViewModel() }
        self.register(EventDetailViewModelType.self) { EventDetailViewModel() }
        self.register(UserDetailViewModelType.self) { UserDetailViewModel() }
        self.register(JoinEventViewModelType.self) { JoinEventViewModel() }

        //* ---------- SERVICES ---------- *//
        self.register(AuthServiceType.self) { AuthService() }
        self.register(UserServiceType.self) { UserService() }
        self.register(MatchServiceType.self) { MatchService() }
        self.register(LeagueServiceType.self) { LeagueService() }
        self.register(EventServiceType.self) { EventService() }
        self.register(PredictServiceType.self) { PredictService() }
    }
}
