//
//  EventsViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import Foundation
import Resolver
import ParseSwift
import Combine

protocol EventsViewModelType {

    var user: CurrentValueSubject<UserModel?, Never> { get }
    
    var events: CurrentValueSubject<[EventModel], Never> { get }

    func createEvent(name: String, selectedLeagues: [LeagueModel], startTimestamp: Int, endTimestamp: Int, imageData: Data?) -> AnyPublisher<Void, ParseError>
    
    func fetchEvents()
}

class EventsViewModel: EventsViewModelType {

    @Injected
    var userService: UserServiceType
    
    @Injected
    var eventService: EventServiceType
    
    var user: CurrentValueSubject<UserModel?, Never> {
        return self.userService.user
    }
    
    var events = CurrentValueSubject<[EventModel], Never>([])
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetchEvents() {
        self.eventService.fetchEventsForUser()
            .flatMap({ [unowned self] events in
                return self.eventService.fetchGlobalEvents()
                    .map { globalEvents in
                        return events + globalEvents
                    }
            })
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] events in
                guard let self else { return }
                let sortedEvents = events.sorted()
                self.events.send(sortedEvents)
            })
            .store(in: &self.cancellables)
    }

    func createEvent(name: String, selectedLeagues: [LeagueModel], startTimestamp: Int, endTimestamp: Int, imageData: Data?) -> AnyPublisher<Void, ParseError> {
        var event = EventModel()
        event.name = name
        event.startTimestamp = startTimestamp
        event.endTimestamp = endTimestamp
        event.eventType = .open
        event.finished = false
        if let imageData = imageData {
            let imageFile = ParseFile(name: "\(event.id)-image", data: imageData)
            event.eventImage = imageFile
        }
        
        return self.eventService.createEvent(event: event, selectedLeagues: selectedLeagues)
    }
}
