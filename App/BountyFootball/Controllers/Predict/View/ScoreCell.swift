//
//  ScoreCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import Kingfisher

class ScoreCell: UICollectionViewCell {
    
    let homeTeamImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 18, weight: .regular)
        return label
    }()
    
    let awayTeamImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = self.isSelected ? UIColor.clear.cgColor : UIColor.borderGray.cgColor
            self.backgroundColor = self.isSelected ? .inactiveGray : .white
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.homeTeamImageView.kf.cancelDownloadTask()
        self.awayTeamImageView.kf.cancelDownloadTask()
        self.homeTeamImageView.image = nil
        self.awayTeamImageView.image = nil
        self.scoreLabel.text = nil
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
    
    func configure(with score: ScoreModel, match: MatchModel) {
        self.homeTeamImageView.kf.setImage(with: URL(string: match.homeTeamImageUrl ?? ""))
        self.awayTeamImageView.kf.setImage(with: URL(string: match.awayTeamImageUrl ?? ""))
        self.scoreLabel.text = "\(score.homeTeamScore)-\(score.awayTeamScore)"
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.borderGray.cgColor
    }
    
    fileprivate func configureAutoLayout() {
        
        self.addSubview(self.homeTeamImageView, anchors: [
            .centerY(to: self.centerYAnchor),
            .leading(to: self.leadingAnchor, constant: 7),
            .height(constant: 20),
            .width(constant: 20)
        ])
        
        self.addSubview(self.scoreLabel, anchors: [
            .centerY(to: self.centerYAnchor),
            .leading(to: self.homeTeamImageView.trailingAnchor, constant: 7),
            .width(constant: 32)
        ])
        
        self.addSubview(self.awayTeamImageView, anchors: [
            .centerY(to: self.centerYAnchor),
            .leading(to: self.scoreLabel.trailingAnchor, constant: 7),
            .height(constant: 20),
            .width(constant: 20)
        ])
    }
    
}
