//
//  UserPredictionCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Kingfisher

class UserPredictionCell: UICollectionViewCell {
    
    let leagueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 12, weight: .regular)
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
    
    let matchStateView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let matchStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 10, weight: .bold)
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 12, weight: .regular)
        return label
    }()
    
    let voteView = VoteView()
    
    let predictionScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 14, weight: .regular)
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.voteView.reset()
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
    
    func configure(with prediction: PredictionModel) {
        self.leagueLabel.text = prediction.league?.name
        
        switch prediction.match?.matchState {
            case .inProgress:
                self.matchStatusLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
                self.matchStatusLabel.text = "LIVE"
            case .finished:
                self.matchStatusLabel.textColor = .black
                self.matchStatusLabel.text = "FT"
            default:
                self.matchStateView.isHidden = true
        }
        
        self.scoreLabel.text = "\(prediction.match?.homeTeamScore ?? 0)-\(prediction.match?.awayTeamScore ?? 0)"
        self.pointsLabel.text = "\(prediction.points ?? 0) p"
        if let displayName = prediction.user?.displayName {
            self.predictionScoreLabel.text = "\(displayName) predicted \(prediction.homeTeamScore ?? 0)-\(prediction.awayTeamScore ?? 0)"
        }
        
        guard let match = prediction.match else { return }
        
        self.voteView.configure(for: match, prediction: prediction)
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .secondaryBackgroundGray
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.voteView.disableButtons()
    }
    
    fileprivate func configureAutoLayout() {
        
        self.addSubview(self.pointsView, anchors: [
            .top(to: self.topAnchor, constant: 14),
            .trailing(to: self.trailingAnchor, constant: 12),
            .height(constant: 28),
            .width(constant: 60)
        ])
        
        self.pointsView.addSubview(self.pointsLabel, anchors: [
            .fill(padding: .init(top: 6, left: 6, bottom: 6, right: 6))
        ])
        
        self.addSubview(self.leagueLabel, anchors: [
            .centerY(to: self.pointsView.centerYAnchor),
            .leading(to: self.leadingAnchor, constant: 12)
        ])
        
        self.addSubview(self.matchStateView, anchors: [
            .centerX(to: self.centerXAnchor),
            .top(to: self.topAnchor, constant: 14)
        ])
        
        self.matchStateView.addSubview(self.matchStatusLabel, anchors: [
            .top(to: self.matchStateView.topAnchor, constant: 7.5),
            .leading(to: self.matchStateView.leadingAnchor, constant: 12.5),
            .bottom(to: self.matchStateView.bottomAnchor, constant: 7.5),
            .height(constant: 12)
        ])
        
        self.matchStateView.addSubview(self.scoreLabel, anchors: [
            .centerY(to: self.matchStateView.centerYAnchor),
            .leading(to: self.matchStatusLabel.trailingAnchor, constant: 6),
            .trailing(to: self.matchStateView.trailingAnchor, constant: 12.5)
        ])
        
        
        self.addSubview(self.voteView, anchors: [
            .top(to: self.pointsView.bottomAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 12),
            .height(constant: 78)
        ])
        
        self.addSubview(self.predictionScoreLabel, anchors: [
            .bottom(to: self.bottomAnchor, constant: 14),
            .leading(to: self.leadingAnchor, constant: 12)
        ])
    }
}
