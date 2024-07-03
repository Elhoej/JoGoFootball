//
//  FilterCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 15/08/2023.
//

import UIKit

protocol FilterCellDelegate: AnyObject {
    func handleFilter()
}

class FilterCell: UICollectionViewCell {
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Filter games", for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterLeagues), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: FilterCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
        self.configureAutoLayout()
    }
    
    @objc fileprivate func filterLeagues() {
        self.delegate?.handleFilter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
        self.configureAutoLayout()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
    }
    
    fileprivate func configureAutoLayout() {
        self.addSubview(self.filterButton, anchors: [
            .top(to: self.topAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 12),
            .bottom(to: self.bottomAnchor, constant: 12)
        ])
    }
}
