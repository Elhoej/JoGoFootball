//
//  PredictDetailViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import Combine
import Resolver
import ParseSwift

protocol PredictDetailViewModelType {
    
    var containerModel: MatchContainerModel { get }
    
    var preSelectedPrediction: TeamPrediction? { get }
    
    func createPrediction(teamPrediction: TeamPrediction, scorePrediction: ScoreModel?) -> AnyPublisher<Void, ParseError>
    
    func updatePrediction(_ prediction: PredictionModel) -> AnyPublisher<Void, ParseError>
}

class PredictDetailViewModel: PredictDetailViewModelType {
    
    @Injected(name: .match)
    var containerModel: MatchContainerModel
    
    @OptionalInjected(name: .preSelectedPrediction)
    var preSelectedPrediction: TeamPrediction?
    
    @Injected
    var predictService: PredictServiceType
    
    @Injected
    var userService: UserServiceType
    
    func createPrediction(teamPrediction: TeamPrediction, scorePrediction: ScoreModel?) -> AnyPublisher<Void, ParseError> {
        guard let user = self.userService.currentUser else {
            return Fail(error: ParseError(code: .missingObjectId, message: "Not logged in")).eraseToAnyPublisher()
        }
        
        let timestamp = Date().timeIntervalSince1970.intValue
        var prediction = PredictionModel(match: self.containerModel.match, user: user, league: self.containerModel.league, teamPrediction: teamPrediction, timestamp: timestamp)
        if let scorePrediction = scorePrediction {
            prediction.homeTeamScore = scorePrediction.homeTeamScore
            prediction.awayTeamScore = scorePrediction.awayTeamScore
        }
        
        return self.predictService.createPrediction(prediction: prediction)
    }
    
    func updatePrediction(_ prediction: PredictionModel) -> AnyPublisher<Void, ParseError> {
        return self.predictService.updatePrediction(prediction)
    }
    
}
