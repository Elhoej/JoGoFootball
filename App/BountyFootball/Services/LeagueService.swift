//
//  LeagueService.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/08/2023.
//

import UIKit
import ParseSwift
import Combine

protocol LeagueServiceType {
    func fetchLeagues() -> AnyPublisher<[LeagueModel], ParseError>
}

class LeagueService: LeagueServiceType {

    fileprivate var cancellables: Set<AnyCancellable> = []

    init() { }

    func fetchLeagues() -> AnyPublisher<[LeagueModel], ParseError> {
        
        return LeagueModel.query()
            .where(equalTo(key: "active", value: true))
            .order([.descending("priority")])
            .findPublisher()
            .eraseToAnyPublisher()
    }
}
