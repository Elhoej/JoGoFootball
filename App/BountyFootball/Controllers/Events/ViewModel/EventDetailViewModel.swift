//
//  EventDetailViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import Resolver
import Combine
import ParseSwift

class DeadlineModel {
    var date: Date
    var progress: Float
    var remaining: String
    
    init(event: EventModel) {
        let date = Date(timeIntervalSince1970: TimeInterval(event.endTimestamp ?? 0))
        self.date = date
        
        let start = Float(event.startTimestamp ?? 0)
        let end = Float(event.endTimestamp ?? 0)
        let now = Float(Date().timeIntervalSince1970)
        let progress = ((now - start) / (end - start))
        self.progress = progress
        
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        switch remaining {
            case let days where days == 0: self.remaining = "Last day!"
            case let days where days < 0: self.remaining = "Finished"
            default: self.remaining = "\(remaining)d"
        }
    }
}

class EventTypeModel {
    var type: EventType
    
    init(event: EventModel) {
        self.type = event.eventType ?? .open
    }
}

class EventRankModel {
    var user: User
    var predictions: [PredictionModel]
    var points: Int
    
    init(user: User, predictions: [PredictionModel]) {
        self.user = user
        self.predictions = predictions
        self.points = predictions.reduce(0) { $0 + ($1.points ?? 0) }
    }
}

extension EventRankModel: Hashable, Equatable {
    static func == (lhs: EventRankModel, rhs: EventRankModel) -> Bool {
        return (
            lhs.user == rhs.user &&
            lhs.predictions == rhs.predictions &&
            lhs.points == rhs.points
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.user.id)
    }
}

extension EventTypeModel: Hashable, Equatable {
    static func == (lhs: EventTypeModel, rhs: EventTypeModel) -> Bool {
        return lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.type)
    }
}

extension DeadlineModel: Hashable, Equatable {
    static func == (lhs: DeadlineModel, rhs: DeadlineModel) -> Bool {
        return lhs.progress == rhs.progress
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.progress)
    }
}

protocol EventDetailViewModelType {
    
    var event: EventModel { get }

    var deadline: DeadlineModel? { get }
    
    var type: EventTypeModel? { get }
    
    func fetchObjectsForEvent() -> AnyPublisher<([EventRankModel], [LeagueModel]), ParseError>
    
    func leaveEvent() -> AnyPublisher<Void, ParseError>
}

class EventDetailViewModel: EventDetailViewModelType {
    
    @Injected(name: .event)
    var event: EventModel
    
    var deadline: DeadlineModel?
    
    var type: EventTypeModel?
    
    @Injected
    var eventSevice: EventServiceType
    
    @Injected
    var predictionService: PredictServiceType
    
    init() {
        self.deadline = DeadlineModel(event: event)
        self.type = EventTypeModel(event: event)
    }
    
    func fetchObjectsForEvent() -> AnyPublisher<([EventRankModel], [LeagueModel]), ParseError> {
        
        if self.event.eventType == .global {
            return self.eventSevice.fetchLeaguesForEvent(self.event)
                .flatMap { leagues in
                    return self.predictionService.fetchPredictions(for: self.event, users: [], leagues: leagues)
                        .map({ ($0, leagues) })
                }
                .map { predictions, leagues in
                    
                    let groupedPredictions = Dictionary(grouping: predictions, by: { $0.user })
                    
                    var rankModels = [EventRankModel]()
                    
                    for user in groupedPredictions.keys {
                        guard let user = user else { continue }
                        let rankModel = EventRankModel(user: user, predictions: groupedPredictions[user] ?? [])
                        rankModels.append(rankModel)
                    }
                    
                    let sortedRankModels = rankModels.sorted(by: { $0.points > $1.points })
                    let sortedLeagueModels = leagues.sorted(by: { ($0.priority ?? 0) > ($1.priority ?? 0) })
                    return (sortedRankModels, sortedLeagueModels)
                }
                .eraseToAnyPublisher()
        } else {
            return Publishers.Zip(self.eventSevice.fetchUsersForEvent(self.event), self.eventSevice.fetchLeaguesForEvent(self.event))
                .flatMap({ users, leagues in
                    return self.predictionService.fetchPredictions(for: self.event, users: users, leagues: leagues)
                        .map({ ($0, users, leagues) })
                })
                .map({ predictions, users, leagues in
                    let rankModels = users.map { user in
                        let filteredPredictions = predictions.filter({ $0.user == user })
                        return EventRankModel(user: user, predictions: filteredPredictions)
                    }
                    let sortedRankModels = rankModels.sorted(by: { $0.points > $1.points })
                    let sortedLeagueModels = leagues.sorted(by: { ($0.priority ?? 0) > ($1.priority ?? 0) })
                    return (sortedRankModels, sortedLeagueModels)
                })
                .eraseToAnyPublisher()
        }
    }
    
    func leaveEvent() -> AnyPublisher<Void, ParseError> {
        return self.eventSevice.leaveEvent(event: self.event)
    }
}
