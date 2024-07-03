//
//  UserHeaderView.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Kingfisher

class UserHeaderView: UICollectionReusableView {
    
    let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let statsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.kf.cancelDownloadTask()
        self.avatarImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    func configure(with user: User, predictions: [PredictionModel]) {
        if let avatarUrl = user.avatar?.url {
            self.avatarImageView.kf.setImage(with: avatarUrl)
        } else {
            self.avatarImageView.image = UIImage.initialsImage(name: user.displayName, size: CGSize(width: 120, height: 120), fontSize: 20)
        }
        
        let correctPredictions = predictions.compactMap({ $0.points }).filter({ $0 > 0 })
        let incorrectPredictions = predictions.compactMap({ $0.points }).filter({ $0 == 0 })
        
        self.statsLabel.text = "\(predictions.count) games predicted this event\n\(correctPredictions.count) correct, \(incorrectPredictions.count) wrong"
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
        
        self.addSubview(avatarImageView, anchors: [
            .top(to: self.topAnchor, constant: 20),
            .centerX(to: self.centerXAnchor),
            .height(constant: 120),
            .width(constant: 120)
        ])
        
        self.addSubview(self.statsLabel, anchors: [
            .top(to: self.avatarImageView.bottomAnchor, constant: 14),
            .centerX(to: self.centerXAnchor)
        ])
    }
}
