//
//  JoinEventViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import Foundation
import Resolver
import Combine
import ParseSwift

protocol JoinEventViewModelType {
    
    func joinEvent(with code: String) -> AnyPublisher<EventModel, ParseError>
    
}

class JoinEventViewModel: JoinEventViewModelType {

    @Injected
    var eventService: EventServiceType
    
    func joinEvent(with code: String) -> AnyPublisher<EventModel, ParseError> {
        return self.eventService.joinEvent(with: code)
    }
    
}
