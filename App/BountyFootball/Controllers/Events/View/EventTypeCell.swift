//
//  EventTypeCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import UIKit

class EventTypeCell: UICollectionViewCell {
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 14, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    func configure(with type: EventTypeModel) {
        switch type.type {
            case .global: self.typeLabel.text = "Global Event.\nAll users are automatically part of this event."
            case .private: self.typeLabel.text = "Private Event.\nOnly the creator of this event can invite users."
            case .open: self.typeLabel.text = "Open Event.\nAll attendees of this event can invite other users"
        }
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.addSubview(self.typeLabel, anchors: [.fill(padding: .init(top: 0, left: 16, bottom: 0, right: 16))])
    }
    
}
