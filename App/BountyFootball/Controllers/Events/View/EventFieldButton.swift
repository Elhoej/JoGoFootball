//
//  EventFieldButton.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit

enum EventValueType {
    case text(String)
    case image
    case `switch`
}

class EventFieldButton: UIButton {
    
    var defaultValue: EventValueType
    var inputText: String? {
        didSet {
            if let inputText = self.inputText {
                self.valueLabel.text = inputText
                self.valueView.backgroundColor = .primaryGreen
            } else {
                self.valueLabel.text = "Pick"
                self.valueView.backgroundColor = .backgroundGray
            }
            self.layoutIfNeeded()
        }
    }
    
    let valueView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundGray
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.checkmarkUnselected.image
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    convenience init(valueType: EventValueType) {
        self.init(frame: .zero)
        self.defaultValue = valueType
        
        switch valueType {
            case .text(let text): self.valueLabel.text = text
            case .image:
                self.valueView.isHidden = true
                self.valueLabel.isHidden = true
                self.checkmarkImageView.isHidden = false
            case .switch:
                print(123)
        }
        
        self.configureView()
    }
    
    override init(frame: CGRect) {
        self.defaultValue = .text("")
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        self.defaultValue = .text("")
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = .appFont(size: 15, weight: .medium)
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        self.addSubview(self.valueView, anchors: [
            .top(to: self.topAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 16),
            .bottom(to: self.bottomAnchor, constant: 12)
        ])
        
        self.valueView.addSubview(self.valueLabel, anchors: [
            .fill(padding: .init(top: 8, left: 16, bottom: 8, right: 16))
        ])
        
        self.addSubview(self.checkmarkImageView, anchors: [
            .top(to: self.topAnchor, constant: 18),
            .trailing(to: self.trailingAnchor, constant: 16),
            .bottom(to: self.bottomAnchor, constant: 18),
            .height(constant: 24),
            .width(constant: 24)
        ])
    }
    
}
