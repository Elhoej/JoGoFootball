//
//  UserDetailViewModel.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import Foundation
import Resolver

protocol UserDetailViewModelType {
    
    var user: User { get }
    
    var predictions: [PredictionModel] { get }
}

class UserDetailViewModel: UserDetailViewModelType {
    
    @Injected(name: .rankModel)
    var rankModel: EventRankModel
    
    var user: User {
        return self.rankModel.user
    }
    
    var predictions: [PredictionModel] {
        if self.user == User.current {
            return self.rankModel.predictions
                .sorted(by: { ($0.match?.startTimestamp ?? 0) > ($1.match?.startTimestamp ?? 0) })
        } else {
            return self.rankModel.predictions
                .filter({ ($0.match?.matchState ?? .notStarted) > .notStarted })
                .sorted(by: { ($0.match?.startTimestamp ?? 0) > ($1.match?.startTimestamp ?? 0) })
        }
    }
}
    
