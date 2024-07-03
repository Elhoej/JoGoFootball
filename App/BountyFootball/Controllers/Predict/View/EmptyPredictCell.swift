//
//  EmptyPredictCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/11/2023.
//

import UIKit

class EmptyPredictCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.emptyPredictImage.image
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No games to show"
        label.textAlignment = .center
        label.textColor = .textGray
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Try to filter games"
        label.textAlignment = .center
        label.textColor = .textGray
        label.font = .appFont(size: 14, weight: .regular)
        return label
    }()
    
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
        self.backgroundColor = .secondaryBackgroundGray
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }
    
    fileprivate func configureAutoLayout() {
        self.addSubview(self.imageView, anchors: [
            .top(to: self.topAnchor, constant: 24),
            .centerX(to: self.centerXAnchor),
            .height(constant: 40),
            .width(constant: 32)
        ])
        
        self.addSubview(self.titleLabel, anchors: [
            .top(to: self.imageView.bottomAnchor, constant: 12),
            .centerX(to: self.centerXAnchor)
        ])
        
        self.addSubview(self.subTitleLabel, anchors: [
            .top(to: self.titleLabel.bottomAnchor, constant: 2),
            .centerX(to: self.centerXAnchor)
        ])
    }
}
