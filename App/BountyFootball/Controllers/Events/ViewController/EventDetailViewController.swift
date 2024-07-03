//
//  EventDetailViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import UIKit
import Combine
import Resolver
import Kingfisher

class EventDetailViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.backgroundColor = .clear
        cv.register(supplementaryView: EventDetailHeaderView.self, type: .header)
        cv.register(cell: DeadlineCell.self)
        cv.register(cell: UserCell.self)
        cv.register(cell: LeagueCell.self)
        cv.register(cell: EventTypeCell.self)
        cv.contentInset = UIEdgeInsets(top: 160 + (self.keyWindow?.safeAreaInsets.top ?? 0), left: 0, bottom: 60, right: 0)
        cv.refreshControl = self.refreshControl
        return cv
    }()
    
    let statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topBarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Media.backIcon.image, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Media.moreIcon.image, for: .normal)
        button.addTarget(self, action: #selector(more), for: .touchUpInside)
        return button
    }()
    
    lazy var addFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add friends", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .appFont(size: 20, weight: .black)
        return label
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.color = .black
        aiv.hidesWhenStopped = true
        aiv.startAnimating()
        return aiv
    }()
    
    var topBarViewHeightAnchor: NSLayoutConstraint?
    var addFriendsButtonWidthAnchor: NSLayoutConstraint?
    var titleLabelLeadingAnchor: NSLayoutConstraint?
    
    let keyWindow = UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .last { $0.isKeyWindow }
    
    @Injected
    var viewModel: EventDetailViewModelType
    var coordinator: CoordinatorType!
    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<EventDetailSection, AnyHashable>!
    
    enum EventDetailSection: String {
        case deadline
        case rank
        case league
        case eventType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
        self.configureAutoLayout()
        self.configureCollectionView()
        self.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    lazy var imageGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.cgColor
        ]
        layer.locations = [0.0 ,0.85, 1.0]
        return layer
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.imageGradientLayer.frame == .zero {
            self.imageGradientLayer.frame = self.topBarImageView.bounds
        }
        self.topBarImageView.layer.addSublayer(imageGradientLayer)
    }
    
    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func more() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
            self.viewModel.leaveEvent()
                .sink { _ in } receiveValue: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: .refreshEvents, object: self)
                }
                .store(in: &self.cancellables)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(sheet, animated: true)
    }
    
    @objc fileprivate func addFriends() {
        try? self.coordinator.transition(to: EventTransition.invite)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.topBarImageView.kf.setImage(with: self.viewModel.event.eventImage?.url)
        self.titleLabel.text = self.viewModel.event.name
        
        if self.viewModel.event.eventType == .global || (self.viewModel.event.finished ?? false) {
            self.addFriendsButton.isHidden = true
            self.moreButton.isHidden = true
        }
    }
    
    var rankModels = [EventRankModel]()
    
    fileprivate func configureBindings() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.refresh()
            }
            .store(in: &self.cancellables)
    }
    
    @objc fileprivate func refresh() {
        self.viewModel.fetchObjectsForEvent()
            .receive(on: RunLoop.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] rankModels, leagues in
                
                guard let self else { return }
                
                self.rankModels = rankModels
                
                var snapshot = NSDiffableDataSourceSnapshot<EventDetailSection, AnyHashable>()
                
                if let deadline = self.viewModel.deadline {
                    snapshot.appendSections([.deadline])
                    snapshot.appendItems([deadline])
                }
                
                if !rankModels.isEmpty {
                    snapshot.appendSections([.rank])
                    snapshot.appendItems(rankModels)
                }
                
                if !leagues.isEmpty {
                    snapshot.appendSections([.league])
                    snapshot.appendItems(leagues)
                }
                
                if let eventType = self.viewModel.type {
                    snapshot.appendSections([.eventType])
                    snapshot.appendItems([eventType])
                }
                
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
    
    @objc fileprivate func handleRefreshControl() {
        self.refresh()
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.collectionView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
        
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
        ])
        self.topBarViewHeightAnchor = self.topBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -240)
        self.topBarViewHeightAnchor?.isActive = true
        
        self.topBarView.addSubview(self.topBarImageView, anchors: [
            .fill()
        ])
        
        self.topBarView.addSubview(self.backButton, anchors: [
            .top(to: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 30),
            .width(constant: 30)
        ])
        
        self.topBarView.addSubview(self.moreButton, anchors: [
            .top(to: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 30),
            .width(constant: 30)
        ])
        
        self.topBarView.addSubview(self.addFriendsButton, anchors: [
            .top(to: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            .trailing(to: self.moreButton.leadingAnchor, constant: 8),
            .height(constant: 30)
        ])
        
        self.addFriendsButtonWidthAnchor = self.addFriendsButton.widthAnchor.constraint(equalToConstant: 116)
        self.addFriendsButtonWidthAnchor?.isActive = true
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .bottom(to: self.topBarView.bottomAnchor, constant: 12),
            .trailing(to: self.addFriendsButton.leadingAnchor, constant: 8)
        ])
        self.titleLabelLeadingAnchor = self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        self.titleLabelLeadingAnchor?.isActive = true
        
        self.view.addSubview(self.loadingIndicator, anchors: [
            .centerX(to: self.view.centerXAnchor),
            .centerY(to: self.view.centerYAnchor)
        ])
    }
    
    fileprivate func configureCollectionView() {
        self.dataSource = .init(collectionView: self.collectionView) {( collectionView, indexPath, content) -> UICollectionViewCell? in
            
            switch content {
                case let item as DeadlineModel:
                    let cell = collectionView.dequeue(cell: DeadlineCell.self, for: indexPath)
                    cell.configure(with: item)
                    return cell
                case let item as EventRankModel:
                    let cell = collectionView.dequeue(cell: UserCell.self, for: indexPath)
                    cell.configure(with: item, position: indexPath.item + 1)
                    return cell
                case let item as LeagueModel:
                    let cell = collectionView.dequeue(cell: LeagueCell.self, for: indexPath)
                    cell.configure(with: item)
                    cell.checkmarkImageView.isHidden = true
                    return cell
                case let item as EventTypeModel:
                    let cell = collectionView.dequeue(cell: EventTypeCell.self, for: indexPath)
                    cell.configure(with: item)
                    return cell
                default: return nil
            }
        }
        
        self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

            guard let self = self else { return nil }

            let section = self.dataSource.sectionIdentifier(for: indexPath.section)

            let header = collectionView.dequeue(supplementaryView: EventDetailHeaderView.self, type: .header, for: indexPath)
            
            switch section {
                case .deadline: header.titleLabel.text = "Deadline"
                case .rank: header.titleLabel.text = "Rank"
                case .league: header.titleLabel.text = "Competitions"
                case .eventType: header.titleLabel.text = "Type"
                default: return nil
            }
            
            return header
        }
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(32))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        self.collectionView.collectionViewLayout = layout
    }
    
}

extension EventDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.collectionView.cellForItem(at: indexPath) is UserCell {
            let rankModel = self.rankModels[indexPath.item]
            try? self.coordinator.transition(to: EventTransition.user(rankModel))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DividerCell {
            if collectionView.numberOfItems(inSection: indexPath.section) == 1 {
                cell.superView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.superView.layer.cornerRadius = 12
                cell.dividerView.isHidden = true
            } else {
                switch indexPath.item {
                    case 0:
                        cell.superView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                        cell.superView.layer.cornerRadius = 12
                    case collectionView.numberOfItems(inSection: indexPath.section) - 1:
                        cell.superView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                        cell.superView.layer.cornerRadius = 12
                        cell.dividerView.isHidden = true
                    default:
                        cell.superView.layer.cornerRadius = 0
                }
            }
        }
    }
}

extension EventDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y - (self.keyWindow?.safeAreaInsets.top ?? 0)
        let absY = abs(offsetY)
        
        print(offsetY)
        print(absY)
        
        let max: CGFloat = 200
        let min: CGFloat = 48
        let fraction = 1.0 - ((absY - min) / (max - min))
        let difference = max - min
        
        let titleLabelMax: CGFloat = 60
        let titleLabelMin: CGFloat = 16
        let titleLabelDifference = titleLabelMax - titleLabelMin
        
        let addFriendsButtonMax: CGFloat = 116
        let addFriendsButtonMin: CGFloat = 30
        let addFriendsButtonDifference = addFriendsButtonMax - addFriendsButtonMin
        
        if offsetY < 0.0 {
            if fraction <= 0.0 {
                self.topBarViewHeightAnchor?.constant = max
                self.titleLabelLeadingAnchor?.constant = titleLabelMin
                self.addFriendsButtonWidthAnchor?.constant = addFriendsButtonMax
                self.topBarImageView.alpha = 1
                self.addFriendsButton.setTitle("Add friends", for: .normal)
                self.addFriendsButton.titleLabel?.alpha = 1
                self.addFriendsButton.setImage(nil, for: .normal)
            } else if fraction >= 1.0 {
                self.topBarViewHeightAnchor?.constant = min
                self.titleLabelLeadingAnchor?.constant = titleLabelMax
                self.addFriendsButtonWidthAnchor?.constant = addFriendsButtonMin
                self.addFriendsButton.setImage(Media.addIcon.image, for: .normal)
                self.addFriendsButton.imageView?.alpha = 1
                self.topBarImageView.alpha = 0
            } else {
                //top view
                let constant = ((difference / 100) * fraction) * 100
                let animationConstant = max - constant
                self.topBarViewHeightAnchor?.constant = animationConstant
                
                //title label
                let titleLabelConstant = ((titleLabelDifference / 100) * fraction) * 100
                self.titleLabelLeadingAnchor?.constant = titleLabelMin + titleLabelConstant
                
                //add friends button
                let addFriendsButtonConstant = ((addFriendsButtonDifference / 100) * fraction) * 100
                let addFriendsButtonAnimationConstant = addFriendsButtonMax - addFriendsButtonConstant
                self.addFriendsButtonWidthAnchor?.constant = addFriendsButtonAnimationConstant
                
                self.topBarImageView.alpha = 1 - fraction
                
                if fraction >= 0.33 && fraction <= 0.66 {
                    self.addFriendsButton.setImage(nil, for: .normal)
                    self.addFriendsButton.setTitle(nil, for: .normal)
                    self.addFriendsButton.titleLabel?.alpha = 0.0
                    self.addFriendsButton.imageView?.alpha = 0.0
                } else if fraction <= 0.33 {
                    self.addFriendsButton.titleLabel?.alpha = 1 - (fraction * 3.33)
                    self.addFriendsButton.setTitle("Add friends", for: .normal)
                } else if fraction >= 0.66 {
                    self.addFriendsButton.imageView?.alpha = (fraction - 0.66) * 3.33
                    self.addFriendsButton.setImage(Media.addIcon.image, for: .normal)
                }
            }
        } else {
            self.topBarViewHeightAnchor?.constant = min
        }
    }
}

extension EventDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
