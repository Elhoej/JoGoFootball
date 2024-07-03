//
//  PredictViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import UIKit
import ParseSwift
import Resolver
import Combine
import CombineCocoa
import Kingfisher

class PredictViewController: UIViewController {

    let topBarView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
 
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Predict"
        label.font = .appFont(size: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    lazy var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(profile), for: .touchUpInside)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.imageView?.clipsToBounds = true
        return button
    }()
    
    lazy var yesterdayButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Yesterday", for: .normal)
        button.setTitleColor(.textGray, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(handleYesterday), for: .touchUpInside)
        return button
    }()
    
    lazy var todayButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Today", for: .normal)
        button.setTitleColor(.textGray, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(handleToday), for: .touchUpInside)
        button.isSelected = true
        return button
    }()
    
    lazy var tomorrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Tomorrow", for: .normal)
        button.setTitleColor(.textGray, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(handleTomorrow), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [self.yesterdayButton, self.todayButton, self.tomorrowButton])
        sv.axis = .horizontal
        sv.distribution = .fillProportionally
        return sv
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 1.5
        view.layer.masksToBounds = true
        return view
    }()
    
    var underlineViewCenterXToYesterdayButtonAnchor: NSLayoutConstraint?
    var underlineViewCenterXToTodayButtonAnchor: NSLayoutConstraint?
    var underlineViewCenterXToTomorrowButtonAnchor: NSLayoutConstraint?
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerBackground
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        return rc
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.color = .black
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.register(cell: PredictCell.self)
        cv.register(cell: FilterCell.self)
        cv.register(cell: EmptyPredictCell.self)
        cv.refreshControl = self.refreshControl
        cv.alpha = 0
        cv.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        cv.scrollIndicatorInsets = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        return cv
    }()
    
    lazy var leftSwipeGesture: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .right
        return swipe
    }()
    
    lazy var rightSwipeGesture: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .left
        return swipe
    }()
    
    enum DayFilter {
        case yesterday
        case today
        case tomorrow
    }
    
    var dataSource: UICollectionViewDiffableDataSource<PredictSection, AnyHashable>!

    @Injected
    var viewModel: PredictViewModelType
    var coordinator: CoordinatorType!
    var cancellables: Set<AnyCancellable> = []
    
    var dayFilter: DayFilter = .today
    
//    Live query
//    lazy var client: ParseLiveQuery = {
//        let client = try! ParseLiveQuery()
//        client.receiveDelegate = self
//        return client
//    }()
    
    lazy var matchLiveQuery = MatchModel.query()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureCollectionView()
        self.configureAutoLayout()
        self.configureBindings()
        self.viewModel.fetchMatches()
//        self.testLiveQuery()
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.collectionView.addGestureRecognizer(self.leftSwipeGesture)
        self.collectionView.addGestureRecognizer(self.rightSwipeGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMatches), name: .refreshMatches, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMatches), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func configureBindings() {
        
        Publishers.Merge(self.leftSwipeGesture.swipePublisher, self.rightSwipeGesture.swipePublisher)
            .sink { [weak self] gesture in
                guard let self else { return }
                switch (gesture, self.dayFilter) {
                    case (self.rightSwipeGesture, .yesterday): self.handleToday()
                    case (self.leftSwipeGesture, .today): self.handleYesterday()
                    case (self.rightSwipeGesture, .today): self.handleTomorrow()
                    case (self.leftSwipeGesture, .tomorrow): self.handleToday()
                    default: break
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.user
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] user in
                guard let user else { return }
                if let imageUrl = user.imageUrl {
                    self?.profileButton.kf.setImage(with: imageUrl, for: .normal)
                } else {
                    self?.profileButton.setImage(UIImage.initialsImage(name: user.displayName), for: .normal)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
                self.viewModel.yesterdayMatches,
                self.viewModel.todayMatches,
                self.viewModel.tomorrowMatches
            )
            .sink { completion in } receiveValue: { [weak self] yesterdayMatches, todayMatches, tomorrowMatches in
                
                guard let self else { return }
                
                self.refreshControl.endRefreshing()
                self.handleSnapshot()
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 20.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] countdown in
                guard let self else { return }
                let now = Date().timeIntervalSince1970.intValue
                let outdatedMatches = self.viewModel.todayMatches.value.filter({ now > ($0.match.startTimestamp ?? Int.max) && $0.match.matchState < .inProgress })
                if !outdatedMatches.isEmpty {
                    self.viewModel.fetchMatches()
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.isLoading
            .scan((false, false)) { ($0.1, $1) }
            .sink { previous, isLoading in
                if previous == isLoading { return }
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.alpha = isLoading ? 0 : 1
                }
            }
            .store(in: &self.cancellables)
    }
    
    fileprivate func handleSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<PredictSection, AnyHashable>()
        
        switch self.dayFilter {
            case .yesterday:
                if !self.viewModel.yesterdayMatches.value.isEmpty {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems(self.viewModel.yesterdayMatches.value)
                } else {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems([Empty()])
                }
            case .today:
                if !self.viewModel.todayMatches.value.isEmpty {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems(self.viewModel.todayMatches.value)
                } else {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems([Empty()])
                }
            case .tomorrow:
                if !self.viewModel.tomorrowMatches.value.isEmpty {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems(self.viewModel.tomorrowMatches.value)
                } else {
                    snapshot.appendSections([PredictSection.vote])
                    snapshot.appendItems([Empty()])
                }
        }
        
        snapshot.appendSections([PredictSection.filter])
        snapshot.appendItems(["filter"])
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
//    func testLiveQuery() {
//        
//        let querySubscription = try? self.matchLiveQuery.subscribeCallback(self.client)
//        
//        querySubscription?.handleSubscribe({ query, isNew in
//            if isNew {
//                print("Successfully subscribed to new query \(query)")
//            } else {
//                print("Successfully updated subscription to new query \(query)")
//            }
//        })
//        
//        querySubscription?.handleEvent({ _, event in
//            switch event {
//                case .entered(let match):
//                    var snapshot = NSDiffableDataSourceSnapshot<PredictSection, AnyHashable>()
//                    snapshot.appendSections([PredictSection.vote])
//                    snapshot.appendItems([match])
//                    self.dataSource?.apply(snapshot, animatingDifferences: false)
//                case .created(let match):
//                    var snapshot = NSDiffableDataSourceSnapshot<PredictSection, AnyHashable>()
//                    snapshot.appendSections([PredictSection.vote])
//                    snapshot.appendItems([match])
//                    self.dataSource?.apply(snapshot, animatingDifferences: false)
//                case .updated(let match):
//                    var snapshot = NSDiffableDataSourceSnapshot<PredictSection, AnyHashable>()
//                    snapshot.appendSections([PredictSection.vote])
//                    snapshot.appendItems([match])
//                    self.dataSource?.apply(snapshot, animatingDifferences: false)
//                default: break
//            }
//        })
//        
//        self.client.sendPing { error in
//            if let error = error {
//                print("Error pinging LiveQuery server: \(error)")
//            } else {
//                print("Successfully pinged server!")
//            }
//        }
//        
//        querySubscription?.handleUnsubscribe({ query in
//            print("Unsubscribed from \(query)")
//        })
//    }
    
    @objc fileprivate func handleRefreshControl() {
        self.viewModel.fetchMatches()
    }
    
    @objc fileprivate func refreshMatches() {
        self.viewModel.isLoading.send(true)
        self.viewModel.fetchMatches()
    }

    @objc fileprivate func profile() {
        try? self.coordinator.transition(to: PredictTransition.settings)
    }
    
    @objc fileprivate func handleYesterday() {
        (self.buttonStackView.arrangedSubviews as? [UIButton])?.forEach({ $0.isSelected = false })
        self.yesterdayButton.isSelected = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.underlineViewCenterXToTodayButtonAnchor?.isActive = false
            self.underlineViewCenterXToTomorrowButtonAnchor?.isActive = false
            self.underlineViewCenterXToYesterdayButtonAnchor?.isActive = true
            self.view.layoutIfNeeded()
        }
        self.dayFilter = .yesterday
        self.handleSnapshot()
    }
    
    @objc fileprivate func handleToday() {
        (self.buttonStackView.arrangedSubviews as? [UIButton])?.forEach({ $0.isSelected = false })
        self.todayButton.isSelected = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.underlineViewCenterXToTomorrowButtonAnchor?.isActive = false
            self.underlineViewCenterXToYesterdayButtonAnchor?.isActive = false
            self.underlineViewCenterXToTodayButtonAnchor?.isActive = true
            self.view.layoutIfNeeded()
        }
        self.dayFilter = .today
        self.handleSnapshot()
    }
    
    @objc fileprivate func handleTomorrow() {
        (self.buttonStackView.arrangedSubviews as? [UIButton])?.forEach({ $0.isSelected = false })
        self.tomorrowButton.isSelected = true
        
        UIView.animate(withDuration: 0.225, delay: 0, options: .curveEaseOut) {
            self.underlineViewCenterXToTodayButtonAnchor?.isActive = false
            self.underlineViewCenterXToYesterdayButtonAnchor?.isActive = false
            self.underlineViewCenterXToTomorrowButtonAnchor?.isActive = true
            self.view.layoutIfNeeded()
        }
        self.dayFilter = .tomorrow
        self.handleSnapshot()
    }
    
    func openPrediction(indexPath: IndexPath, prediction: TeamPrediction?) {
        var matchContainer: MatchContainerModel
        
        switch self.dayFilter {
            case .yesterday:
                matchContainer = self.viewModel.yesterdayMatches.value[indexPath.item]
            case .today:
                matchContainer = self.viewModel.todayMatches.value[indexPath.item]
            case .tomorrow:
                matchContainer = self.viewModel.tomorrowMatches.value[indexPath.item]
        }
        
        if matchContainer.match.matchState != .notStarted { return }
        
        try? self.coordinator.transition(to: PredictTransition.detail(matchContainer, prediction))
    }

    fileprivate func configureAutoLayout() {
        
        self.view.addSubview(self.loadingIndicator, anchors: [
            .centerX(to: self.view.centerXAnchor),
            .centerY(to: self.view.centerYAnchor)
        ])
        
        //CollectionView
        self.view.addSubview(self.collectionView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
        
        //TopBarView
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.safeAreaLayoutGuide.topAnchor, constant: -94)
        ])

        self.topBarView.contentView.addSubview(self.profileButton, anchors: [
            .trailing(to: self.topBarView.trailingAnchor, constant: 16),
            .bottom(to: self.topBarView.bottomAnchor, constant: 52),
            .height(constant: 34),
            .width(constant: 34)
        ])

        self.topBarView.contentView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.profileButton.centerYAnchor),
            .leading(to: self.topBarView.leadingAnchor, constant: 16)
        ])
        
        self.topBarView.contentView.addSubview(self.buttonStackView, anchors: [
            .bottom(to: self.topBarView.bottomAnchor, constant: 6),
            .leading(to: self.topBarView.leadingAnchor, constant: 56),
            .trailing(to: self.topBarView.trailingAnchor, constant: 56),
            .height(constant: 28)
        ])
        
        self.topBarView.contentView.addSubview(self.underlineView, anchors: [
            .bottom(to: self.topBarView.bottomAnchor),
            .width(constant: 44),
            .height(constant: 3)
        ])
        
        self.underlineViewCenterXToYesterdayButtonAnchor = self.underlineView.centerXAnchor.constraint(equalTo: self.yesterdayButton.centerXAnchor)
        self.underlineViewCenterXToTodayButtonAnchor = self.underlineView.centerXAnchor.constraint(equalTo: self.todayButton.centerXAnchor)
        self.underlineViewCenterXToTomorrowButtonAnchor = self.underlineView.centerXAnchor.constraint(equalTo: self.tomorrowButton.centerXAnchor)
        self.underlineViewCenterXToTodayButtonAnchor?.isActive = true

        self.view.addSubview(self.seperatorView, anchors: [
            .top(to: self.topBarView.bottomAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 1)
        ])
    }
}

extension PredictViewController: ParseLiveQueryDelegate {
    func received(_ error: Error) {
        print(error)
    }

    func closedSocket(_ code: URLSessionWebSocketTask.CloseCode?, reason: Data?) {
        print("Socket closed with \(String(describing: code)) and \(String(describing: reason))")
    }
}

extension PredictViewController: PredictCellDelegate {

    func selected(prediction: TeamPrediction, _ cell: PredictCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        self.openPrediction(indexPath: indexPath, prediction: prediction)
    }
}

extension PredictViewController: FilterCellDelegate {
    func handleFilter() {
        try? self.coordinator.transition(to: PredictTransition.filter(presenter: self))
    }
}

extension PredictViewController: ChooseLeagueViewControllerDelegate {
    func didChoose(leagues: [LeagueModel]) {
        let leagueIds = leagues.compactMap({ $0.leagueId })
        self.viewModel.saveSelectedLeagueIds(with: leagueIds)
        self.refreshMatches()
    }
}
