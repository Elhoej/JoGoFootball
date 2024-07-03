//
//  UserViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Resolver

class UserDetailViewController: UIViewController {
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(supplementaryView: UserHeaderView.self, type: .header)
        cv.register(cell: UserPredictionCell.self)
        return cv
    }()
    
    @Injected
    var viewModel: UserDetailViewModelType
    var coordinator: CoordinatorType!
    var dataSource: UICollectionViewDiffableDataSource<UserDetailSection, AnyHashable>!
    
    enum UserDetailSection: String {
        case prediction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
        self.configureAutoLayout()
        self.configureCollectionView()
    }
    
    fileprivate func configureView() {
        self.titleLabel.text = self.viewModel.user.isCurrentUser ? "\(self.viewModel.user.displayName ?? "") (You)" : "\(self.viewModel.user.displayName ?? "")"
    }
    
    fileprivate func configureBindings() { }
    
    fileprivate func configureCollectionView() {
        self.dataSource = .init(collectionView: self.collectionView) {( collectionView, indexPath, content) -> UICollectionViewCell? in
            
            switch content {
                case let item as PredictionModel:
                    let cell = collectionView.dequeue(cell: UserPredictionCell.self, for: indexPath)
                    cell.configure(with: item)
                    return cell
                default: return nil
            }
        }
        
        self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

            guard let self = self else { return nil }
            
            let header = collectionView.dequeue(supplementaryView: UserHeaderView.self, type: .header, for: indexPath)
            header.configure(with: self.viewModel.user, predictions: self.viewModel.predictions)
            return header
        }
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(175))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.edgeSpacing = .init(leading: .none, top: .fixed(5), trailing: .none, bottom: .fixed(5))

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        self.collectionView.collectionViewLayout = layout
        
        var snapshot = NSDiffableDataSourceSnapshot<UserDetailSection, AnyHashable>()
        snapshot.appendSections([.prediction])
        snapshot.appendItems(self.viewModel.predictions)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 54)
        ])
        
        self.topBarView.addSubview(self.closeButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.closeButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.collectionView, anchors: [
            .top(to: self.topBarView.bottomAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
    }
    
    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }
    
}
