//
//  EventDetailHeaderView.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import UIKit

class EventDetailHeaderView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.font = .appFont(size: 15, weight: .medium)
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
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
        self.addSubview(self.titleLabel, anchors: [
            .bottom(to: self.bottomAnchor),
            .leading(to: self.leadingAnchor)
        ])
    }
}

