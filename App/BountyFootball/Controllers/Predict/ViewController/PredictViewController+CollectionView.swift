//
//  PredictViewController+CollectionView.swift
//  BountyFootball
//
//  Created by Simon Elhøj on 19/02/2023.
//

import UIKit

extension PredictViewController {
    
    enum PredictSection: String {
        case vote
        case filter
    }
    
    func configureCollectionView() {
        self.dataSource = .init(collectionView: self.collectionView) {( collectionView, indexPath, content) -> UICollectionViewCell? in
            
            switch content {
                case let item as MatchContainerModel:
                    let cell = collectionView.dequeue(cell: PredictCell.self, for: indexPath)
                    cell.delegate = self
                    cell.configure(with: item)
                    return cell
                case _ as String:
                    let cell = collectionView.dequeue(cell: FilterCell.self, for: indexPath)
                    cell.delegate = self
                    return cell
                case _ as Empty:
                    let cell = collectionView.dequeue(cell: EmptyPredictCell.self, for: indexPath)
                    return cell
                default: return nil
            }
        }
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let content = self.dataSource.itemIdentifier(for: IndexPath(item: 0, section: sectionIndex))
            
            switch content {
                case _ as MatchContainerModel:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(132))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(132))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    group.edgeSpacing = .init(leading: .none, top: .fixed(4), trailing: .none, bottom: .fixed(4))

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
                    return section
                case _ as String:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(84))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    return section
                case _ as Empty:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(138))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = .init(top: 12, leading: 12, bottom: 6, trailing: 12)
                    return section
                default: return nil
            }
            
        }
        
        self.collectionView.collectionViewLayout = layout
    }
}

extension PredictViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.collectionView.cellForItem(at: indexPath) is PredictCell else { return }
        self.openPrediction(indexPath: indexPath, prediction: nil)
    }
}
