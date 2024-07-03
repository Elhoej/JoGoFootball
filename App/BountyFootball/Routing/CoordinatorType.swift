//
//  CoordinatorType.swift
//  Hangout
//
//  Created by Simon Elhøj Steinmejer on 10/03/2022.
//

import UIKit

public protocol CoordinatorType: NSObjectProtocol {

    var baseController: UIViewController? { get }

    func start() throws

    func stop() throws

    func transition(to transition: Transition) throws

    func route(to route: Route)

}

public extension CoordinatorType {

    func stop() throws { }

}

public protocol Transition { }

public protocol Route { }
