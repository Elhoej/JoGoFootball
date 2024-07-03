//
//  UserCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import UIKit
import Kingfisher

protocol DividerCell {
    var superView: UICollectionViewCell { get }
    var dividerView: UIView { get }
}

class UserCell: UICollectionViewCell, DividerCell {
    
    var superView: UICollectionViewCell { return self }
    
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 15, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 14, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let pointsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = .borderGray
        return view
    }()
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.chevronRightIcon.image
        return iv
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .dividerBackground
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.cornerRadius = 0
        self.dividerView.isHidden = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    func configure(with rankModel: EventRankModel, position: Int) {
        self.rankLabel.text = "\(position)"
        self.nameLabel.text = rankModel.user.displayName
        self.nameLabel.font = rankModel.user.isCurrentUser ? .appFont(size: 14, weight: .bold) : .appFont(size: 14, weight: .regular)
        if let imageUrl = rankModel.user.avatar?.url {
            self.avatarImageView.kf.setImage(with: imageUrl)
        } else {
            self.avatarImageView.image = UIImage.initialsImage(name: rankModel.user.displayName)
        }
        self.pointsLabel.text = "\(rankModel.points) p"
        self.pointsView.backgroundColor = rankModel.user.isCurrentUser ? .black : .borderGray
        self.pointsLabel.textColor = rankModel.user.isCurrentUser ? .white : .black
        self.layoutIfNeeded()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        
        self.addSubview(self.rankLabel, anchors: [
            .leading(to: self.leadingAnchor, constant: 12),
            .centerY(to: self.centerYAnchor),
            .width(constant: 32)
        ])
        
        self.addSubview(self.avatarImageView, anchors: [
            .leading(to: self.rankLabel.trailingAnchor, constant: 8),
            .centerY(to: self.centerYAnchor),
            .height(constant: 28),
            .width(constant: 28)
        ])
        
        self.addSubview(self.chevronImageView, anchors: [
            .trailing(to: self.trailingAnchor, constant: 12),
            .centerY(to: self.centerYAnchor),
            .height(constant: 12),
            .width(constant: 6)
        ])
        
        self.addSubview(self.pointsView, anchors: [
            .trailing(to: self.chevronImageView.leadingAnchor, constant: 12),
            .centerY(to: self.centerYAnchor),
            .height(constant: 28),
            .width(constant: 60)
        ])
        
        self.pointsView.addSubview(self.pointsLabel, anchors: [
            .fill(padding: .init(top: 6, left: 6, bottom: 6, right: 6))
        ])
        
        self.addSubview(self.nameLabel, anchors: [
            .leading(to: self.avatarImageView.trailingAnchor, constant: 8),
            .centerY(to: self.centerYAnchor),
            .trailing(to: self.pointsView.leadingAnchor, constant: 16)
        ])
        
        self.addSubview(self.dividerView, anchors: [
            .bottom(to: self.bottomAnchor),
            .leading(to: self.leadingAnchor),
            .trailing(to: self.trailingAnchor),
            .height(constant: 1)
        ])
    }
    
}
