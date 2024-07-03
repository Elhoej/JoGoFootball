//
//  PredictService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import Combine
import ParseSwift

protocol PredictServiceType {
    
    func createPrediction(prediction: PredictionModel) -> AnyPublisher<Void, ParseError>
    
    func updatePrediction(_ prediction: PredictionModel) -> AnyPublisher<Void, ParseError>
    
    func fetchPredictions(for matches: [MatchModel], user: User) -> AnyPublisher<[PredictionModel], ParseError>
    
    func fetchPredictions(for event: EventModel, users: [User], leagues: [LeagueModel]) -> AnyPublisher<[PredictionModel], ParseError>
}

class PredictService: PredictServiceType {
    
    func createPrediction(prediction: PredictionModel) -> AnyPublisher<Void, ParseError> {
        return prediction.savePublisher()
            .map({ _ in () })
            .eraseToAnyPublisher()
    }
    
    func updatePrediction(_ prediction: PredictionModel) -> AnyPublisher<Void, ParseError> {
        return prediction.savePublisher()
            .map({ _ in () })
            .eraseToAnyPublisher()
    }
    
    func fetchPredictions(for matches: [MatchModel], user: User) -> AnyPublisher<[PredictionModel], ParseError> {
        
        let batchSize = 20
        
        if matches.count > batchSize {
            let batches = stride(from: 0, to: matches.count, by: batchSize).map {
                Array(matches[$0..<min($0 + batchSize, matches.count)])
            }
            
            do {
                let queries = try batches.map { batch in
                    return try PredictionModel.query
                        .where(containedIn(key: "match", array: batch))
                        .where(equalTo(key: "user", object: user))
                        .include("match")
                        .findPublisher()
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(queries)
                    .collect()
                    .map({ $0.reduce([], +) })
                    .eraseToAnyPublisher()
                
            } catch {
                return Fail(error: ParseError(code: .objectNotFound, message: "Couldnt find predictions for matches"))
                    .eraseToAnyPublisher()
            }
        } else {
            do {
                return try PredictionModel.query
                    .where(containedIn(key: "match", array: matches))
                    .where(equalTo(key: "user", object: user))
                    .include("match")
                    .findPublisher()
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: ParseError(code: .objectNotFound, message: "Couldnt find predictions for matches"))
                    .eraseToAnyPublisher()
            }
        }
    }
    
    func fetchPredictions(for event: EventModel, users: [User], leagues: [LeagueModel]) -> AnyPublisher<[PredictionModel], ParseError> {
        
        if event.eventType == .global {
            do {
                return try PredictionModel.query()
                    .where(containedIn(key: "league", array: leagues))
                    .where("timestamp" >= event.startTimestamp)
                    .where("timestamp" <= event.endTimestamp)
                    .include("user")
                    .include("match")
                    .include("league")
                    .findAllPublisher(batchLimit: 200)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: ParseError(code: .objectNotFound, message: "Couldnt find predictions for global event"))
                    .eraseToAnyPublisher()
            }
        } else {
            do {
                return try PredictionModel.query()
                    .where(containedIn(key: "user", array: users))
                    .where(containedIn(key: "league", array: leagues))
                    .where("timestamp" >= event.startTimestamp)
                    .where("timestamp" <= event.endTimestamp)
                    .include("user")
                    .include("match")
                    .include("league")
                    .findAllPublisher(batchLimit: 200)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: ParseError(code: .objectNotFound, message: "Couldnt find predictions for event, users, leagues"))
                    .eraseToAnyPublisher()
            }
        }
    }
}
