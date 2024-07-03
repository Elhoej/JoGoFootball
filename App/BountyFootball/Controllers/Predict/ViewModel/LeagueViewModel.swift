//
//  LeagueViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/08/2023.
//

import Foundation
import Combine
import ParseSwift
import Resolver

protocol LeagueViewModelType {
    
    func fetchLeagues() -> AnyPublisher<[LeagueModel], ParseError>
    
    var selectedLeagueIds: [Int] { get }
}

class LeagueViewModel: LeagueViewModelType {
    
    @Injected
    var leagueService: LeagueServiceType
    
    @UserDefault("User-selectedLeagueIds", defaultValue: [])
    var selectedLeagueIds: [Int]
    
    func fetchLeagues() -> AnyPublisher<[LeagueModel], ParseError> {
        return self.leagueService.fetchLeagues()
    }
    
}
