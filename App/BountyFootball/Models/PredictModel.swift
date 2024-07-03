//
//  PredictModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import ParseSwift

enum TeamPrediction: String, Codable {
    case home = "HOME"
    case away = "AWAY"
    case draw = "DRAW"
}

struct PredictionModel: ParseObject {
    
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var match: MatchModel?
    var user: User?
    var league: LeagueModel?
    @NullCodable var homeTeamScore: Int?
    @NullCodable var awayTeamScore: Int?
    var points: Int?
    var teamPrediction: TeamPrediction?
    var timestamp: Int?
    
    static var className: String {
        return "Prediction"
    }
}

extension PredictionModel {
    init(match: MatchModel, user: User, league: LeagueModel, teamPrediction: TeamPrediction, timestamp: Int) {
        self.match = match
        self.user = user
        self.league = league
        self.teamPrediction = teamPrediction
        self.timestamp = timestamp
    }
}
