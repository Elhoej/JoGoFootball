//
//  VoteView.swift
//  BountyFootball
//
//  Created by Simon Elhøj on 19/02/2023.
//

import UIKit
import Kingfisher

protocol VoteViewDelegate: AnyObject {
    func selected(prediction: TeamPrediction)
}

class VoteView: UIView {
    
    lazy var homeTeamButton: CenteredButton = {
        let button = CenteredButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 12, weight: .regular)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.borderGray.cgColor
        button.addTarget(self, action: #selector(teamOneVoted), for: .touchUpInside)
        return button
    }()
    
    lazy var drawButton: CenteredButton = {
        let button = CenteredButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = .appFont(size: 12, weight: .regular)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.borderGray.cgColor
        button.addTarget(self, action: #selector(drawVoted), for: .touchUpInside)
        return button
    }()
    
    lazy var awayTeamButton: CenteredButton = {
        let button = CenteredButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 12, weight: .regular)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.borderGray.cgColor
        button.addTarget(self, action: #selector(teamTwoVoted), for: .touchUpInside)
        return button
    }()
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
    
    var selectedPrediction: TeamPrediction? {
        didSet {
            guard let selectedPrediction = self.selectedPrediction else { return }
            self.delegate?.selected(prediction: selectedPrediction)
        }
    }
    
    var prediction: PredictionModel?
    
    weak var delegate: VoteViewDelegate?
    
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
    
    func configure(for container: MatchContainerModel) {
        self.prediction = container.prediction
        self.homeTeamButton.kf.setImage(with: URL(string: container.match.homeTeamImageUrl ?? ""), for: .normal)
        self.homeTeamButton.setTitle(container.match.homeTeamName, for: .normal)
        self.awayTeamButton.kf.setImage(with: URL(string: container.match.awayTeamImageUrl ?? ""), for: .normal)
        self.awayTeamButton.setTitle(container.match.awayTeamName, for: .normal)
        
        if container.match.matchState > .notStarted {
            [self.homeTeamButton, self.drawButton, self.awayTeamButton].forEach { button in
                button.layer.borderColor = UIColor.clear.cgColor
                button.layer.borderWidth = 0
            }
        }
        
        if let prediction = container.prediction {
            self.setPrediction(prediction.teamPrediction)
        }
    }
    
    func configure(for match: MatchModel, prediction: PredictionModel) {
        let containerModel = MatchContainerModel(match: match, league: prediction.league, prediction: prediction)
        self.configure(for: containerModel)
    }
    
    func disableButtons() {
        [self.homeTeamButton, self.drawButton, self.awayTeamButton].forEach({ $0.isUserInteractionEnabled = false })
        self.addGestureRecognizer(self.tapGesture)
    }
    
    @objc fileprivate func handleTap(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self)
        switch point {
            case let point where self.homeTeamButton.frame.contains(point):
                self.selectedPrediction = .home
            case let point where self.drawButton.frame.contains(point):
                self.selectedPrediction = .draw
            case let point where self.awayTeamButton.frame.contains(point):
                self.selectedPrediction = .away
            default: break
        }
    }
    
    func setPrediction(_ prediction: TeamPrediction?) {
        self.selectedPrediction = prediction
        switch prediction {
            case .home: self.teamOneVoted()
            case .away: self.teamTwoVoted()
            case .draw: self.drawVoted()
            default: break
        }
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
        self.drawButton.setImage(Media.drawImage.image, for: .normal)
    }
    
    func reset() {
        self.homeTeamButton.kf.cancelImageDownloadTask()
        self.awayTeamButton.kf.cancelImageDownloadTask()
        self.homeTeamButton.setImage(nil, for: .normal)
        self.homeTeamButton.setTitle(nil, for: .normal)
        self.awayTeamButton.setImage(nil, for: .normal)
        self.awayTeamButton.setTitle(nil, for: .normal)
        [self.homeTeamButton, self.drawButton, self.awayTeamButton].forEach({ button in
            button.isSelected = false
            button.backgroundColor = .clear
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.borderGray.cgColor
        })
    }
    
    fileprivate func configureAutoLayout() {
        
        let stackView = UIStackView(arrangedSubviews: [self.homeTeamButton, self.drawButton, self.awayTeamButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView, anchors: [.fill()])
    }
    
    @objc fileprivate func teamOneVoted() {
        [self.drawButton, self.awayTeamButton].forEach({ $0.reset() })
        self.homeTeamButton.isSelected = true
        self.selectedPrediction = .home
        
        if let prediction = self.prediction {
            switch prediction.points {
                case .some(let points) where points > 0:
                    self.homeTeamButton.backgroundColor = .correctGreen
                case .some(let points) where points <= 0:
                    self.homeTeamButton.backgroundColor = .wrongRed
                case .none:
                    self.homeTeamButton.backgroundColor = .inactiveGray
                default: break
            }
        } else {
            self.homeTeamButton.backgroundColor = .inactiveGray
        }
    }
    
    @objc fileprivate func drawVoted() {
        [self.homeTeamButton, self.awayTeamButton].forEach({ $0.reset() })
        self.drawButton.isSelected = true
        self.selectedPrediction = .draw
        
        if let prediction = self.prediction {
            switch prediction.points {
                case .some(let points) where points > 0:
                    self.drawButton.backgroundColor = .correctGreen
                case .some(let points) where points <= 0:
                    self.drawButton.backgroundColor = .wrongRed
                case .none:
                    self.drawButton.backgroundColor = .inactiveGray
                default: break
            }
        } else {
            self.drawButton.backgroundColor = .inactiveGray
        }
    }
    
    @objc fileprivate func teamTwoVoted() {
        [self.homeTeamButton, self.drawButton].forEach({ $0.reset() })
        self.awayTeamButton.isSelected = true
        self.selectedPrediction = .away
        
        if let prediction = self.prediction {
            switch prediction.points {
                case .some(let points) where points > 0:
                    self.awayTeamButton.backgroundColor = .correctGreen
                case .some(let points) where points <= 0:
                    self.awayTeamButton.backgroundColor = .wrongRed
                case .none:
                    self.awayTeamButton.backgroundColor = .inactiveGray
                default: break
            }
        } else {
            self.awayTeamButton.backgroundColor = .inactiveGray
        }
    }
}
