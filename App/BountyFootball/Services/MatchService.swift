//
//  PredictService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/08/2023.
//

import Foundation
import Combine
import Resolver
import ParseSwift

protocol MatchServiceType {
    
    func fetchMatches(for leagueIds: [Int]) -> AnyPublisher<[MatchModel], ParseError>
    
}

class MatchService: MatchServiceType {
    
    func fetchMatches(for leagueIds: [Int]) -> AnyPublisher<[MatchModel], ParseError> {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -2, to: startOfDay)!
        let yesterdayMidnight = calendar.startOfDay(for: yesterday)
        let tomorrow = calendar.date(byAdding: .day, value: 2, to: startOfDay)!
        let tomorrowMidnight = calendar.startOfDay(for: tomorrow)
        
        let batchSize = 20
        
        if leagueIds.count > batchSize {
            let batches = stride(from: 0, to: leagueIds.count, by: batchSize).map {
                Array(leagueIds[$0..<min($0 + batchSize, leagueIds.count)])
            }
            
            do {
                let queries = batches.map { batch in
                    return MatchModel.query()
                        .where(containedIn(key: "leagueId", array: batch))
                        .where("date" >= yesterdayMidnight)
                        .where("date" <= tomorrowMidnight)
                        .limit(999)
                        .findPublisher()
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(queries)
                    .collect()
                    .map({ $0.reduce([], +) })
                    .eraseToAnyPublisher()
                
            }
        } else {
            return MatchModel.query()
                .where(containedIn(key: "leagueId", array: leagueIds))
                .where("date" >= yesterdayMidnight)
                .where("date" <= tomorrowMidnight)
                .limit(999)
                .findPublisher()
                .eraseToAnyPublisher()
        }
    }
    
    init() { }
}
