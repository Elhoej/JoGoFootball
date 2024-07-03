//
//  EventDurationViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 18/11/2023.
//

import UIKit
import Resolver
import Combine
import CombineCocoa

enum EventDuration: String {
    case short = "In 3 days"
    case medium = "In 1 week"
    case long = "In 1 month"
}

protocol EventDurationViewControllerDelegate: AnyObject {
    func didSelect(eventDuration: EventDuration)
}

class EventDurationViewController: UIViewController {
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundGray
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.text = "Event ends"
        return label
    }()
    
    lazy var shortDurationButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Select"))
        button.setTitle("In 3 days", for: .normal)
        button.addTarget(self, action: #selector(shortDuration), for: .touchUpInside)
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    lazy var mediumDurationButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Select"))
        button.setTitle("In 1 week", for: .normal)
        button.addTarget(self, action: #selector(mediumDuration), for: .touchUpInside)
        button.layer.maskedCorners = []
        return button
    }()
    
    lazy var longDurationButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Select"))
        button.setTitle("In 1 month", for: .normal)
        button.addTarget(self, action: #selector(longDuration), for: .touchUpInside)
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    @Injected
    var viewModel: EventsViewModelType
    var coordinator: CoordinatorType!
    weak var delegate: EventDurationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureAutoLayout()
    }
    
    @objc fileprivate func cancel() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func shortDuration() {
        self.delegate?.didSelect(eventDuration: .short)
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func mediumDuration() {
        self.delegate?.didSelect(eventDuration: .medium)
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func longDuration() {
        self.delegate?.didSelect(eventDuration: .long)
        self.dismiss(animated: true)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 54)
        ])
        
        self.topBarView.addSubview(self.cancelButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.cancelButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [self.shortDurationButton, self.mediumDurationButton, self.longDurationButton])
        stackView.spacing = 1
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        self.view.addSubview(stackView, anchors: [
            .top(to: self.topBarView.bottomAnchor, constant: 20),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 182)
        ])
    }
}
