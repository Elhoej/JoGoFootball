//
//  RankViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import UIKit
import Resolver
import Combine

class EventsViewController: UIViewController {

    let topBarView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .extraLight)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
 
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Events"
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
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerBackground
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.register(cell: EventCell.self)
        cv.register(supplementaryView: EventHeaderView.self, type: .header)
        cv.contentInset = UIEdgeInsets(top: 48, left: 0, bottom: 12, right: 0)
        cv.refreshControl = self.refreshControl
        return cv
    }()
    
    enum EventSection: String {
        case events
        case finished
    }
    
    var dataSource: UICollectionViewDiffableDataSource<EventSection, EventModel>!
    
    @Injected
    var viewModel: EventsViewModelType
    var coordinator: CoordinatorType!
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureCollectionView()
        self.configureAutoLayout()
        self.configureBindings()
        self.viewModel.fetchEvents()
    }
    
    @objc fileprivate func refresh() {
        self.viewModel.fetchEvents()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .refreshEvents, object: nil)
    }
    
    fileprivate func configureBindings() {
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
        

        self.viewModel.events
            .sink { [weak self] events in
                
                self?.refreshControl.endRefreshing()
                
                var snapshot = NSDiffableDataSourceSnapshot<EventSection, EventModel>()

                if !events.isEmpty {
                    snapshot.appendSections([.events])
                    snapshot.appendItems(events)
                }
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.refresh()
            }
            .store(in: &self.cancellables)
    }

    @objc fileprivate func profile() {
        try? self.coordinator.transition(to: EventTransition.settings)
    }
    
    fileprivate func configureAutoLayout() {
        
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
            .bottom(to: self.view.safeAreaLayoutGuide.topAnchor, constant: -48)
        ])

        self.topBarView.contentView.addSubview(self.profileButton, anchors: [
            .trailing(to: self.topBarView.trailingAnchor, constant: 16),
            .bottom(to: self.topBarView.bottomAnchor, constant: 6),
            .height(constant: 34),
            .width(constant: 34)
        ])

        self.topBarView.contentView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.profileButton.centerYAnchor),
            .leading(to: self.topBarView.leadingAnchor, constant: 16)
        ])
        
        self.view.addSubview(self.seperatorView, anchors: [
            .top(to: self.topBarView.bottomAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 1)
        ])
    }
    
    func configureCollectionView() {
        self.dataSource = .init(collectionView: self.collectionView) {( collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: EventCell.self, for: indexPath)
            cell.configure(for: content)
            return cell
        }
        
        self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            let headerView = collectionView.dequeue(supplementaryView: EventHeaderView.self, type: .header, for: indexPath)
            headerView.delegate = self
            return headerView
        }
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
//            let content = self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: sectionIndex))
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
            
            let size = (self.view.frame.width - (12 * 3)) / 2
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(size))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.edgeSpacing = .init(leading: .none, top: .fixed(6), trailing: .none, bottom: .fixed(6))

            let containerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(size))
            let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: containerGroupSize, subitems: [item, group])
                    
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        self.collectionView.collectionViewLayout = layout
    }

}

extension EventsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = self.viewModel.events.value[indexPath.item]
        try? self.coordinator.transition(to: EventTransition.detail(event))
    }
}

extension EventsViewController: EventHeaderViewDelegate {
    func joinEvent() {
        try? self.coordinator.transition(to: EventTransition.join(self))
    }
    
    func createEvent() {
        try? self.coordinator.transition(to: EventTransition.create)
    }
}

extension EventsViewController: JoinEventViewControllerDelegate {
    func didJoin(event: EventModel) {
        try? self.coordinator.transition(to: EventTransition.detail(event))
    }
}
