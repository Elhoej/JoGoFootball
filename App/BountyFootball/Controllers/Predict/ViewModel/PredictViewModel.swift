//
//  PredictViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 17/07/2022.
//

import Foundation
import Resolver
import ParseSwift
import Combine

protocol PredictViewModelType {

    var user: CurrentValueSubject<UserModel?, Never> { get }
    
    var yesterdayMatches: CurrentValueSubject<[MatchContainerModel], Never> { get }
    
    var todayMatches: CurrentValueSubject<[MatchContainerModel], Never> { get }
    
    var tomorrowMatches: CurrentValueSubject<[MatchContainerModel], Never> { get }
    
    var isLoading: CurrentValueSubject<Bool, Never> { get }

    func fetchMatches()
    
    func saveSelectedLeagueIds(with leagueIds: [Int])
}

class PredictViewModel: PredictViewModelType {

    @Injected
    var userService: UserServiceType
    
    @Injected
    var matchService: MatchServiceType
    
    @Injected
    var leagueService: LeagueServiceType
    
    @Injected
    var predictService: PredictServiceType
    
    var user: CurrentValueSubject<UserModel?, Never> {
        return self.userService.user
    }
    
    @UserDefault("User-selectedLeagueIds", defaultValue: [])
    var selectedLeagueIds: [Int]
    
    var yesterdayMatches = CurrentValueSubject<[MatchContainerModel], Never>([])
    var todayMatches = CurrentValueSubject<[MatchContainerModel], Never>([])
    var tomorrowMatches = CurrentValueSubject<[MatchContainerModel], Never>([])
    var isLoading = CurrentValueSubject<Bool, Never>(true)
    var predictions = [PredictionModel]()
    var cancellables: Set<AnyCancellable> = []
    
    func fetchMatches() {
        
        guard let user = self.userService.currentUser else { return }
        
        self.leagueService.fetchLeagues()
            .flatMap { [unowned self] leagues in
                let leagueIds = self.selectedLeagueIds.isEmpty ? leagues.prefix(10).compactMap({ $0.leagueId }) : self.selectedLeagueIds
                return self.matchService.fetchMatches(for: leagueIds)
                    .map({ (leagues, $0) })
            }
            .flatMap({ [unowned self] leagues, matches in
                return self.predictService.fetchPredictions(for: matches, user: user)
                    .map({ return (leagues, matches, $0) })
            })
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] leagues, matches, predictions in
                
                guard let self else { return }
                
                let containerModels = matches.map { match in
                    let prediction = predictions.first(where: { $0.match == match })
                    let league = leagues.first(where: { $0.leagueId == match.leagueId })
                    return MatchContainerModel(match: match, league: league, prediction: prediction)
                }
                
                let calendar = Calendar.current
                
                let yesterdayMatches = containerModels.filter({ calendar.isDateInYesterday($0.match.date!) }).sorted(by: { $0.match < $1.match })
                let todayMatches = containerModels.filter({ calendar.isDateInToday($0.match.date!) }).sorted(by: { $0.match < $1.match })
                let tomorrowMatches = containerModels.filter({ calendar.isDateInTomorrow($0.match.date!) }).sorted(by: { $0.match < $1.match })
                
                self.yesterdayMatches.send(yesterdayMatches)
                self.todayMatches.send(todayMatches)
                self.tomorrowMatches.send(tomorrowMatches)
                self.isLoading.send(false)
            })
            .store(in: &self.cancellables)
    }
    

    func saveSelectedLeagueIds(with leagueIds: [Int]) {
        self.selectedLeagueIds = leagueIds
    }
}
