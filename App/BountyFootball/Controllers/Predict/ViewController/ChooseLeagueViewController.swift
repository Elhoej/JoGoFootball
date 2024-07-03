//
//  ChooseLeagueViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import Resolver

protocol ChooseLeagueViewControllerDelegate: AnyObject {
    func didChoose(leagues: [LeagueModel])
}

class ChooseLeagueViewController: UIViewController {
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()
    
    lazy var chooseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black.withAlphaComponent(0.3), for: .disabled)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(didChooseLeagues), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.register(cell: LeagueCell.self)
        cv.allowsMultipleSelection = true
        return cv
    }()

    @Injected(name: .preselectLeagues)
    var preselectLeagues: Bool
    
    @Injected
    var viewModel: LeagueViewModelType
    var coordinator: CoordinatorType!
    weak var delegate: ChooseLeagueViewControllerDelegate?
    var cancellabes: Set<AnyCancellable> = []
    
    var leagues = [LeagueModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }
    
    @objc fileprivate func didChooseLeagues() {
        guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems else { return }
        let selectedLeagues = selectedIndexPaths.compactMap { indexPath in
            return self.leagues[indexPath.item]
        }
        self.delegate?.didChoose(leagues: selectedLeagues)
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func cancel() {
        self.dismiss(animated: true)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .white
    }
    
    fileprivate func configureBindings() {
        self.viewModel.fetchLeagues()
            .sink { _ in } receiveValue: { [weak self] leagueModels in
                
                guard let self else { return }
                
                self.leagues = leagueModels
                self.collectionView.reloadData()
                
                if self.preselectLeagues {
                    self.preselectUserLeagues()
                }
            }
            .store(in: &cancellabes)
    }
    
    fileprivate func preselectUserLeagues(defaultIds: [Int]? = nil) {
        let defaultLeagueIds = self.leagues.compactMap({ $0.leagueId })
        
        (self.viewModel.selectedLeagueIds.isEmpty ? defaultLeagueIds : self.viewModel.selectedLeagueIds).forEach({ id in
            if let index = self.leagues.firstIndex(where: { $0.leagueId == id }) {
                self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
            }
        })
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 54)
        ])
        
        self.topBarView.addSubview(self.cancelButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.cancelButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.topBarView.addSubview(self.chooseButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 60)
        ])
        
        self.view.addSubview(self.collectionView, anchors: [
            .top(to: self.topBarView.bottomAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
    }
}

extension ChooseLeagueViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.leagues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: LeagueCell.self, for: indexPath)
        let league = self.leagues[indexPath.item]
        cell.configure(with: league)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if (self.collectionView.indexPathsForSelectedItems?.count ?? 0) >= 10 {
//            let alert = UIAlertController(title: "You can maximum select 10 competitions", message: "This limitation will be removed in the future", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default))
//            self.present(alert, animated: true)
//            return false
//        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.collectionView.indexPathsForSelectedItems?.isEmpty ?? true {
            self.chooseButton.isEnabled = false
        } else {
            self.chooseButton.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if self.collectionView.indexPathsForSelectedItems?.isEmpty ?? true {
            self.chooseButton.isEnabled = false
        } else {
            self.chooseButton.isEnabled = true
        }
    }
}
