//
//  EventService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import Foundation
import ParseSwift
import Combine
import Resolver

protocol EventServiceType {
    
    func fetchGlobalEvents() -> AnyPublisher<[EventModel], ParseError>
    
    func fetchEventsForUser() -> AnyPublisher<[EventModel], ParseError>
    
    func fetchUsersForEvent(_ event: EventModel) -> AnyPublisher<[User], ParseError>
    
    func fetchLeaguesForEvent(_ event: EventModel) -> AnyPublisher<[LeagueModel], ParseError>
    
    func createEvent(event: EventModel, selectedLeagues: [LeagueModel]) -> AnyPublisher<Void, ParseError>
    
    func leaveEvent(event: EventModel) -> AnyPublisher<Void, ParseError>
    
    func joinEvent(with code: String) -> AnyPublisher<EventModel, ParseError>
}

class EventService: EventServiceType {
    
    @Injected
    var userService: UserServiceType
    
    func fetchGlobalEvents() -> AnyPublisher<[EventModel], ParseError> {
        return EventModel.query()
            .where(equalTo(key: "eventType", value: EventType.global.rawValue))
//            .where(equalTo(key: "finished", value: true))
            .order([.descending("startTimestamp")])
            .findPublisher()
            .eraseToAnyPublisher()
    }
    
    func fetchEventsForUser() -> AnyPublisher<[EventModel], ParseError> {

        guard let user = self.userService.currentUser else {
            return Fail(error: ParseError(code: .unknownError, message: ""))
                .eraseToAnyPublisher()
        }
        
        do {
            return try EventModel.query()
                .where(equalTo(key: "users", object: user))
                .where("eventType" != EventType.global.rawValue)
                .order([.descending("startTimestamp")])
                .findPublisher()
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ParseError(code: .unknownError, message: "try catch failed"))
                .eraseToAnyPublisher()
        }
    }
    
    func fetchUsersForEvent(_ event: EventModel) -> AnyPublisher<[User], ParseError> {
        do {
            return try User.queryRelations("users", parent: event)
                .findPublisher()
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ParseError(code: .unknownError, message: "Couldnt find users for event"))
                .eraseToAnyPublisher()
        }
    }
    
    func fetchLeaguesForEvent(_ event: EventModel) -> AnyPublisher<[LeagueModel], ParseError> {
        do {
            return try LeagueModel.queryRelations("leagues", parent: event)
                .findPublisher()
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ParseError(code: .unknownError, message: "Couldnt find users for event"))
                .eraseToAnyPublisher()
        }
    }
    
    func createEvent(event: EventModel, selectedLeagues: [LeagueModel]) -> AnyPublisher<Void, ParseError> {

        return event.savePublisher()
            .flatMap { event in
                guard let user = self.userService.currentUser, let relation = event.relation else {
                    return Fail<Void, ParseError>(error: ParseError(code: .objectNotFound, message: "Couldnt find user or event relation"))
                        .eraseToAnyPublisher()
                }
                do {
                    return try Publishers.Zip(
                        relation.add("users", objects: [user]).savePublisher(),
                        relation.add("leagues", objects: selectedLeagues).savePublisher()
                    )
                    .map({ _ in () })
                    .eraseToAnyPublisher()
                } catch {
                    return Fail<Void, ParseError>(error: ParseError(code: .objectNotFound, message: "Failed to ass users and leagues to event relation"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func leaveEvent(event: EventModel) -> AnyPublisher<Void, ParseError> {
        guard let user = self.userService.currentUser, let relation = event.relation else {
            return Fail<Void, ParseError>(error: ParseError(code: .objectNotFound, message: "Couldnt find user or event relation"))
                .eraseToAnyPublisher()
        }
        
        do {
            return try relation.remove([user])
                .savePublisher()
                .map({ _ in () })
                .eraseToAnyPublisher()
        } catch {
            return Fail<Void, ParseError>(error: ParseError(code: .objectNotFound, message: "Failed to remove user from event relation"))
                .eraseToAnyPublisher()
        }
    }
    
    func joinEvent(with code: String) -> AnyPublisher<EventModel, ParseError> {
        return EventModel.query()
            .where(equalTo(key: "inviteCode", value: code))
            .firstPublisher()
            .flatMap({ event in
                
                guard let user = self.userService.currentUser, let relation = event.relation else {
                    return Fail<EventModel, ParseError>(error: ParseError(code: .objectNotFound, message: "Couldnt find user or event relation"))
                        .eraseToAnyPublisher()
                }
                
                do {
                    return try relation.add("users", objects: [user])
                        .savePublisher()
                        .map({ _ in event })
                        .eraseToAnyPublisher()
                } catch {
                    return Fail<EventModel, ParseError>(error: ParseError(code: .objectNotFound, message: "Failed to add user to event relation"))
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
}
