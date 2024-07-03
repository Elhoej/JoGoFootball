//
//  LeagueCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Kingfisher

class LeagueCell: UICollectionViewCell, DividerCell {
    
    var superView: UICollectionViewCell { return self }
    
    let leagueImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let leagueNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 14, weight: .regular)
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.checkmarkUnselected.image
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerBackground
        return view
    }()

    
    override var isSelected: Bool {
        didSet {
            self.checkmarkImageView.image = self.isSelected ? Media.checkmarkSelected.image : Media.checkmarkUnselected.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
        self.configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
        self.configureAutoLayout()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
    }
    
    func configure(with league: LeagueModel) {
        self.leagueImageView.kf.setImage(with: league.logo?.url)
        self.leagueNameLabel.text = league.name
    }
    
    fileprivate func configureAutoLayout() {
        self.addSubview(self.leagueImageView, anchors: [
            .leading(to: self.leadingAnchor, constant: 16),
            .centerY(to: self.centerYAnchor),
            .width(constant: 30),
            .height(constant: 30)
        ])
        
        self.addSubview(self.checkmarkImageView, anchors: [
            .centerY(to: self.centerYAnchor),
            .trailing(to: self.trailingAnchor, constant: 16),
            .height(constant: 24),
            .width(constant: 24)
        ])
        
        self.addSubview(self.leagueNameLabel, anchors: [
            .centerY(to: self.centerYAnchor),
            .leading(to: self.leagueImageView.trailingAnchor, constant: 12),
            .trailing(to: self.checkmarkImageView.leadingAnchor, constant: 18)
        ])
        
        self.addSubview(self.dividerView, anchors: [
            .bottom(to: self.bottomAnchor),
            .leading(to: self.leadingAnchor),
            .trailing(to: self.trailingAnchor),
            .height(constant: 1)
        ])
    }
}


