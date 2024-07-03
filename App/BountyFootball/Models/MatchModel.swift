//
//  MatchModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 15/08/2023.
//

import Foundation
import ParseSwift

struct MatchModel: ParseObject {

    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
    
    var matchId: Int!
    var leagueId: Int?
    var startTimestamp: Int?
    var date: Date?
    var statusShort: MatchStatus?
    var statusLong: String?
    var timeElapsed: Int?
    var homeTeamName: String?
    var homeTeamImageUrl: String?
    var awayTeamName: String?
    var awayTeamImageUrl: String?
    var homeTeamScore: Int?
    var awayTeamScore: Int?
    
    static var className: String {
        return "Match"
    }
}

extension MatchModel {
    var matchState: MatchState {
        return switch self.statusShort {
            case .TBD, .NS: .notStarted
            case .firstHalf, .HT, .secondHalf, .ET, .BT, .P, .INT, .LIVE: .inProgress
            case .FT, .AET, .PEN: .finished
            default: .notStarted
        }
    }
}

enum MatchState: Int, Comparable {
    static func < (lhs: MatchState, rhs: MatchState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case notStarted = 1
    case inProgress = 2
    case finished = 3
}

extension MatchModel: Equatable {
    static func == (lhs: MatchModel, rhs: MatchModel) -> Bool {
        return lhs.objectId == rhs.objectId && lhs.matchId == rhs.matchId && lhs.startTimestamp == rhs.startTimestamp && lhs.statusShort == rhs.statusShort && lhs.timeElapsed == rhs.timeElapsed && lhs.date == rhs.date
    }
}

extension MatchModel: Comparable {
    static func < (lhs: MatchModel, rhs: MatchModel) -> Bool {
        if lhs.matchState == rhs.matchState {
            return lhs.startTimestamp ?? 0 < rhs.startTimestamp ?? 0
        } else {
            return lhs.matchState < rhs.matchState
        }
    }
}

enum MatchStatus: String, Codable {
    case TBD
    case NS
    case firstHalf = "1H"
    case HT
    case secondHalf = "2H"
    case ET
    case BT
    case P
    case SUSP
    case INT
    case FT
    case AET
    case PEN
    case PST
    case CANC
    case ABD
    case AWD
    case WO
    case LIVE
    case unknown
}
