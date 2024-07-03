//
//  MatchContainerModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation

class MatchContainerModel {
    
    var match: MatchModel
    var league: LeagueModel?
    var prediction: PredictionModel?
    
    init(match: MatchModel, league: LeagueModel?, prediction: PredictionModel? = nil) {
        self.match = match
        self.league = league
        self.prediction = prediction
    }
}

extension MatchContainerModel: Hashable, Equatable {
    static func == (lhs: MatchContainerModel, rhs: MatchContainerModel) -> Bool {
        return lhs.match == rhs.match && lhs.prediction == rhs.prediction
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.match.id)
    }
}
