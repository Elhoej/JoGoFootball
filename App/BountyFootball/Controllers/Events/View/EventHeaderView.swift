//
//  EventHeaderView.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit

protocol EventHeaderViewDelegate: AnyObject {
    func joinEvent()
    func createEvent()
}

class EventHeaderView: UICollectionReusableView {
    
    lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(joinEvent), for: .touchUpInside)
        return button
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: EventHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [self.joinButton, self.createButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView, anchors: [
            .top(to: self.topAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 6),
            .trailing(to: self.trailingAnchor, constant: 6),
            .bottom(to: self.bottomAnchor, constant: 8)
        ])
    }
    
    @objc fileprivate func joinEvent() {
        self.delegate?.joinEvent()
    }
    
    @objc fileprivate func createEvent() {
        self.delegate?.createEvent()
    }
    
}
