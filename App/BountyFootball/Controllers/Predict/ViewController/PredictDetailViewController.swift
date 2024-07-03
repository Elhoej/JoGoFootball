//
//  PredictDetailViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import Resolver
import Kingfisher

class PredictDetailViewController: UIViewController {
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    let countdownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()
    
    let leagueLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.text = "Serie A"
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 12, weight: .regular)
        label.text = "18:30"
        return label
    }()
    
    let avatarStackView = AvatarStackView(maxWidth: 110.0, itemSize: CGSize(width: 24, height: 24))
    
    let predictMatchLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.text = "How will the match end?"
        return label
    }()
    
    let predictMatchPointView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = .borderGray
        return view
    }()
    
    let predictMatchPointLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "1 p"
        return label
    }()
    
    lazy var voteView: VoteView = {
        let voteView = VoteView()
        voteView.delegate = self
        return voteView
    }()
    
    let predictScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.text = "Predict the scoreline"
        label.isHidden = true
        return label
    }()
    
    let predictScorePointView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = .borderGray
        return view
    }()
    
    let predictScorePointLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "3 p"
        return label
    }()
    
    lazy var scoreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(cell: ScoreCell.self)
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    lazy var predictButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.backgroundColor = .gray
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Choose your prediction", for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(predict), for: .touchUpInside)
        button.isEnabled = false
        button.isHidden = true
        return button
    }()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    
    
    var coordinator: CoordinatorType!
    
    let homeScores = [
        ScoreModel(homeTeamScore: 1, awayTeamScore: 0),
        ScoreModel(homeTeamScore: 2, awayTeamScore: 0),
        ScoreModel(homeTeamScore: 2, awayTeamScore: 1),
        ScoreModel(homeTeamScore: 3, awayTeamScore: 0),
        ScoreModel(homeTeamScore: 3, awayTeamScore: 1),
        ScoreModel(homeTeamScore: 3, awayTeamScore: 2),
        ScoreModel(homeTeamScore: 4, awayTeamScore: 0),
        ScoreModel(homeTeamScore: 4, awayTeamScore: 1),
        ScoreModel(homeTeamScore: 4, awayTeamScore: 2),
        ScoreModel(homeTeamScore: 4, awayTeamScore: 3),
        ScoreModel(homeTeamScore: 5, awayTeamScore: 0),
        ScoreModel(homeTeamScore: 5, awayTeamScore: 1),
        ScoreModel(homeTeamScore: 5, awayTeamScore: 2),
        ScoreModel(homeTeamScore: 5, awayTeamScore: 3),
        ScoreModel(homeTeamScore: 5, awayTeamScore: 4),
    ]
    
    let drawScores = (0...5).map({ ScoreModel(homeTeamScore: $0, awayTeamScore: $0) })
    
    let awayScores = [
        ScoreModel(homeTeamScore: 0, awayTeamScore: 1),
        ScoreModel(homeTeamScore: 0, awayTeamScore: 2),
        ScoreModel(homeTeamScore: 1, awayTeamScore: 2),
        ScoreModel(homeTeamScore: 0, awayTeamScore: 3),
        ScoreModel(homeTeamScore: 1, awayTeamScore: 3),
        ScoreModel(homeTeamScore: 2, awayTeamScore: 3),
        ScoreModel(homeTeamScore: 0, awayTeamScore: 4),
        ScoreModel(homeTeamScore: 1, awayTeamScore: 4),
        ScoreModel(homeTeamScore: 2, awayTeamScore: 4),
        ScoreModel(homeTeamScore: 3, awayTeamScore: 4),
        ScoreModel(homeTeamScore: 0, awayTeamScore: 5),
        ScoreModel(homeTeamScore: 1, awayTeamScore: 5),
        ScoreModel(homeTeamScore: 2, awayTeamScore: 5),
        ScoreModel(homeTeamScore: 3, awayTeamScore: 5),
        ScoreModel(homeTeamScore: 4, awayTeamScore: 5),
    ]
    
    @Injected
    var viewModel: PredictDetailViewModelType
    var cancellables: Set<AnyCancellable> = []
    var selectedTeamPrediction = CurrentValueSubject<TeamPrediction?, Never>(nil)
    var selectedScorePrediction = CurrentValueSubject<ScoreModel?, Never>(nil)
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }
    
    @objc fileprivate func predict() {
        guard let teamPrediction = self.selectedTeamPrediction.value else { return }
        
        if var currentPrediction = self.viewModel.containerModel.prediction {
            self.updatePrediction(&currentPrediction, with: teamPrediction)
        } else {
            self.createPrediction(with: teamPrediction)
        }
    }
    
    fileprivate func createPrediction(with teamPrediction: TeamPrediction) {
        self.predictButton.isBusy = true
        self.viewModel.createPrediction(teamPrediction: teamPrediction, scorePrediction: self.selectedScorePrediction.value)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    self?.predictButton.isBusy = false
                    NotificationCenter.default.post(name: .refreshMatches, object: self)
                }
            } receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
    }
    
    fileprivate func updatePrediction(_ prediction: inout PredictionModel, with teamPrediction: TeamPrediction) {
        prediction.teamPrediction = teamPrediction
        if let score = self.selectedScorePrediction.value {
            prediction.homeTeamScore = score.homeTeamScore
            prediction.awayTeamScore = score.awayTeamScore
        } else {
            prediction.homeTeamScore = nil
            prediction.awayTeamScore = nil
        }
        self.predictButton.isBusy = true
        
        self.viewModel.updatePrediction(prediction)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    self?.predictButton.isBusy = false
                    NotificationCenter.default.post(name: .refreshMatches, object: self)
                }
            } receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
    }
    
    @objc fileprivate func cancel() {
        self.dismiss(animated: true)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .white
        self.leagueLabel.text = self.viewModel.containerModel.league?.name
        let startTimeDate = Date(timeIntervalSince1970: Double(self.viewModel.containerModel.match.startTimestamp ?? 0))
        let startTimeString = self.dateFormatter.string(from: startTimeDate)
        self.timeLabel.text = startTimeString
        self.voteView.configure(for: self.viewModel.containerModel)
        
        if let prediction = self.viewModel.containerModel.prediction {
            self.configureCurrentPrediction(prediction)
        }
        
        //Disabled for now
//        if let preSelectedPrediction = self.viewModel.preSelectedPrediction {
//            self.selectedTeamPrediction.send(preSelectedPrediction)
//        }

        let calendar = Calendar.current
        if let date = self.viewModel.containerModel.match.date, 
            calendar.isDateInToday(date) {
            self.startCountdown()
        } else {
            self.countdownLabel.text = "Tomorrow"
        }
    }
    
    fileprivate func configureCurrentPrediction(_ prediction: PredictionModel) {
        self.selectedTeamPrediction.send(prediction.teamPrediction)
        if let homeTeamScore = prediction.homeTeamScore, let awayTeamScore = prediction.awayTeamScore {
            let score = ScoreModel(homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore)
            
            self.selectedScorePrediction.send(score)

            switch prediction.teamPrediction {
                case .home:
                    guard let index = self.homeScores.firstIndex(of: score) else { return }
                    self.scoreCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                case .away:
                    guard let index = self.awayScores.firstIndex(of: score) else { return }
                    self.scoreCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                case .draw:
                    guard let index = self.drawScores.firstIndex(of: score) else { return }
                    self.scoreCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                default: break
            }
        }
    }
    
    fileprivate func configureBindings() {
        Publishers.CombineLatest(
            self.selectedTeamPrediction,
            self.selectedScorePrediction
        )
        .sink { [weak self] teamPrediction, scorePrediction in
            guard let self else { return }
            switch (teamPrediction, scorePrediction) {
                case (.some(teamPrediction), .some(scorePrediction)):
                    self.predictButton.isEnabled = true
                    self.predictButton.backgroundColor = .primaryGreen
                    self.predictButton.setTitle("Predict (4 points maximum)", for: .normal)
                    self.predictButton.isHidden = false
                case (.some(teamPrediction), .none):
                    self.predictButton.isEnabled = true
                    self.predictButton.backgroundColor = .primaryGreen
                    self.predictButton.setTitle("Predict (1 points maximum)", for: .normal)
                    self.predictButton.isHidden = false
                case (.none, .some(scorePrediction)):
                    self.predictButton.isHidden = true
                    self.predictButton.isEnabled = false
                    self.predictButton.backgroundColor = .gray
                case (.none, .none):
                    self.predictButton.isHidden = true
                    self.predictButton.isEnabled = false
                    self.predictButton.backgroundColor = .gray
                    self.predictButton.setTitle("Choose your prediction", for: .normal)
                default: break
            }
        }
        .store(in: &cancellables)
        
        self.selectedTeamPrediction
            .map({ $0 == nil })
            .sink { [weak self] hidden in
                self?.predictScoreLabel.isHidden = hidden
                self?.predictScorePointLabel.isHidden = hidden
                self?.predictScorePointView.isHidden = hidden
            }
            .store(in: &cancellables)
        
        self.selectedTeamPrediction
            .dropFirst()
            .sink { [weak self] _ in
                self?.selectedScorePrediction.send(nil)
                self?.scoreCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    fileprivate func startCountdown() {
        let now = Date().timeIntervalSince1970.intValue
        let difference = (self.viewModel.containerModel.match.startTimestamp ?? 0) - now
        let countdown = self.secondsToHoursMinutesSeconds(difference)
        self.countdownLabel.text = String(format: "%02i:%02i:%02i", countdown.0, countdown.1, countdown.2)
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map({ [weak self] _ -> (Int, Int, Int) in
                guard let self else { return (0, 0, 0) }
                let now = Date().timeIntervalSince1970.intValue
                let difference = (self.viewModel.containerModel.match.startTimestamp ?? 0) - now
                let countdown = self.secondsToHoursMinutesSeconds(difference)
                return countdown
            })
            .sink { [weak self] countdown in
                if countdown <= (0, 0, 0) {
                    self?.dismiss(animated: true)
                }
                self?.countdownLabel.text = String(format: "%02i:%02i:%02i", countdown.0, countdown.1, countdown.2)
            }
            .store(in: &self.cancellables)
    }
    
    fileprivate func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.cancelButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.view.addSubview(self.countdownLabel, anchors: [
            .centerY(to: self.cancelButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.leagueLabel, anchors: [
            .top(to: self.view.topAnchor, constant: 85),
            .leading(to: self.view.leadingAnchor, constant: 24)
        ])
        
        self.view.addSubview(self.timeLabel, anchors: [
            .centerY(to: self.leagueLabel.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.avatarStackView, anchors: [
            .centerY(to: self.leagueLabel.centerYAnchor),
            .trailing(to: self.view.trailingAnchor, constant: 24)
        ])
        
        self.view.addSubview(self.predictMatchLabel, anchors: [
            .top(to: self.leagueLabel.bottomAnchor, constant: 48),
            .leading(to: self.view.leadingAnchor, constant: 24)
        ])
        
        self.view.addSubview(self.predictMatchPointView, anchors: [
            .centerY(to: self.predictMatchLabel.centerYAnchor),
            .trailing(to: self.view.trailingAnchor, constant: 24),
            .height(constant: 28),
            .width(constant: 60)
        ])
        
        self.predictMatchPointView.addSubview(self.predictMatchPointLabel, anchors: [
            .fill(padding: .init(top: 6, left: 6, bottom: 6, right: 6))
        ])
        
        self.view.addSubview(self.voteView, anchors: [
            .top(to: self.predictMatchLabel.bottomAnchor, constant: 15),
            .leading(to: self.view.leadingAnchor, constant: 24),
            .trailing(to: self.view.trailingAnchor, constant: 24),
            .height(constant: 78)
        ])
        
        self.view.addSubview(self.predictScoreLabel, anchors: [
            .top(to: self.voteView.bottomAnchor, constant: 42),
            .leading(to: self.view.leadingAnchor, constant: 24)
        ])
        
        self.view.addSubview(self.predictScorePointView, anchors: [
            .centerY(to: self.predictScoreLabel.centerYAnchor),
            .trailing(to: self.view.trailingAnchor, constant: 24),
            .height(constant: 28),
            .width(constant: 60)
        ])
        
        self.predictScorePointView.addSubview(self.predictScorePointLabel, anchors: [
            .fill(padding: .init(top: 6, left: 6, bottom: 6, right: 6))
        ])
        
        self.view.addSubview(self.scoreCollectionView, anchors: [
            .top(to: self.predictScoreLabel.bottomAnchor, constant: 15),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 78)
        ])
        
        self.view.addSubview(self.predictButton, anchors: [
            .bottom(to: self.view.bottomAnchor, constant: 50),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
    }
}

extension PredictDetailViewController: VoteViewDelegate {
    func selected(prediction: TeamPrediction) {
        self.selectedTeamPrediction.send(prediction)
    }
}

extension PredictDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.selectedTeamPrediction.value {
            case .home: return self.homeScores.count
            case .draw: return self.drawScores.count
            case .away: return self.awayScores.count
            case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ScoreCell.self, for: indexPath)
        switch self.selectedTeamPrediction.value {
            case .home: cell.configure(with: self.homeScores[indexPath.item], match: self.viewModel.containerModel.match)
            case .draw: cell.configure(with: self.drawScores[indexPath.item], match: self.viewModel.containerModel.match)
            case .away: cell.configure(with: self.awayScores[indexPath.item], match: self.viewModel.containerModel.match)
            default: break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var score: ScoreModel?
        
        switch self.selectedTeamPrediction.value {
            case .home: score = self.homeScores[indexPath.item]
            case .draw: score = self.drawScores[indexPath.item]
            case .away: score = self.awayScores[indexPath.item]
            default: break
        }
        
        if score == self.selectedScorePrediction.value {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.selectedScorePrediction.send(nil)
        } else {
            self.selectedScorePrediction.send(score)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 78)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


struct ScoreModel: Equatable {
    var homeTeamScore: Int
    var awayTeamScore: Int
}
