//
//  PredictCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj on 14/01/2023.
//

import UIKit
import Resolver
import Combine
import Kingfisher

protocol PredictCellDelegate: AnyObject {
    func selected(prediction: TeamPrediction, _ cell: PredictCell)
}

class PredictCell: UICollectionViewCell {
    
    let leagueNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontFamily.Inter.regular.font(size: 12)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = FontFamily.Inter.regular.font(size: 12)
        label.isHidden = true
        return label
    }()
    
    let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 10, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let predictionScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 14, weight: .regular)
        label.isHidden = true
        return label
    }()
    var predictionScoreLabelHeightAnchor: NSLayoutConstraint?
    
    let avatarStackView = AvatarStackView(maxWidth: 110.0, itemSize: CGSize(width: 24, height: 24))
    
    let voteView = VoteView()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    
    @Injected
    var userService: UserServiceType
    weak var delegate: PredictCellDelegate?
    var cancellables: Set<AnyCancellable> = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.voteView.reset()
        self.timeLabel.text = nil
        self.leagueNameLabel.text = nil
        self.statusView.isHidden = true
        self.timeLabel.isHidden = true
        self.statusLabel.text = nil
        self.scoreLabel.text = nil
        self.predictionScoreLabel.isHidden = true
        self.predictionScoreLabelHeightAnchor?.constant = 0
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
    
    func configure(with container: MatchContainerModel) {
        self.leagueNameLabel.text = container.league?.name
        
        let startDate = Date(timeIntervalSince1970: TimeInterval(container.match.startTimestamp ?? 0))
        let startString = self.dateFormatter.string(from: startDate)
        self.timeLabel.text = startString
        
        self.voteView.configure(for: container)
        self.voteView.disableButtons()
        
        switch container.match.matchState {
            case .notStarted:
                self.statusView.isHidden = true
                self.timeLabel.isHidden = false
                self.backgroundColor = .white
            case .inProgress:
                self.timeLabel.isHidden = true
                self.backgroundColor = .secondaryBackgroundGray
                self.statusLabel.text = "LIVE"
                self.statusLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
                self.scoreLabel.text = "\(container.match.homeTeamScore ?? 0)-\(container.match.awayTeamScore ?? 0)"
                self.statusView.isHidden = false
            case .finished:
                self.timeLabel.isHidden = true
                self.backgroundColor = .secondaryBackgroundGray
                self.statusLabel.text = "FT"
                self.statusLabel.textColor = .black
                self.statusView.isHidden = false
                self.scoreLabel.text = "\(container.match.homeTeamScore ?? 0)-\(container.match.awayTeamScore ?? 0)"
        }
        
        if let prediction = container.prediction {
            if let homeTeamScore = prediction.homeTeamScore, let awayTeamScore = prediction.awayTeamScore {
                self.predictionScoreLabel.text = "You predicted \(homeTeamScore)-\(awayTeamScore)"
                self.predictionScoreLabel.isHidden = false
                self.predictionScoreLabelHeightAnchor?.constant = 20
            }
        }
        
        self.layoutIfNeeded()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.voteView.delegate = self
    }
    
    fileprivate func configureAutoLayout() {
        self.addSubview(self.leagueNameLabel, anchors: [
            .top(to: self.topAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 12)
        ])
        
        self.addSubview(self.timeLabel, anchors: [
            .centerX(to: self.centerXAnchor),
            .top(to: self.topAnchor, constant: 12)
        ])
        
        self.addSubview(self.statusView, anchors: [
            .centerX(to: self.centerXAnchor),
            .top(to: self.topAnchor, constant: 6),
            .height(constant: 28)
        ])
        
        self.statusView.addSubview(self.statusLabel, anchors: [
            .leading(to: self.statusView.leadingAnchor, constant: 12),
            .centerY(to: self.statusView.centerYAnchor)
        ])
        
        self.statusView.addSubview(self.scoreLabel, anchors: [
            .trailing(to: self.statusView.trailingAnchor, constant: 12),
            .centerY(to: self.statusView.centerYAnchor),
            .leading(to: self.statusLabel.trailingAnchor, constant: 6)
        ])
        
        self.addSubview(self.avatarStackView, anchors: [
            .top(to: self.topAnchor, constant: 8),
            .trailing(to: self.trailingAnchor, constant: 12)
        ])
        
        self.addSubview(self.voteView, anchors: [
            .top(to: self.statusView.bottomAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 12),
            .height(constant: 78)
        ])
        
        self.addSubview(self.predictionScoreLabel, anchors: [
            .top(to: self.voteView.bottomAnchor, constant: 12),
            .bottom(to: self.bottomAnchor, constant: 14),
            .leading(to: self.leadingAnchor, constant: 12)
        ])
        self.predictionScoreLabelHeightAnchor = self.predictionScoreLabel.heightAnchor.constraint(equalToConstant: 0)
        self.predictionScoreLabelHeightAnchor?.isActive = true
    }
    
}

extension PredictCell: VoteViewDelegate {
    func selected(prediction: TeamPrediction) {
        self.delegate?.selected(prediction: prediction, self)
    }
}
