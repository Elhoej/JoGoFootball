//
//  SettingsButton.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 20/07/2022.
//

import UIKit

class SettingsButton: UIButton {

    var title: String? {
        didSet {
            self.textLabel.text = self.title
        }
    }

    var image: UIImage? {
        didSet {
            self.iconImageView.image = self.image
        }
    }
    
    var hideChevron: Bool = false {
        didSet {
            self.chevronImageView.isHidden = self.hideChevron
        }
    }

    fileprivate let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    fileprivate let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.chevronRightIcon.image
        return iv
    }()

    fileprivate let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureAutoLayout()
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureAutoLayout()
        self.configureView()
    }

    fileprivate func configureView() {
        self.titleLabel?.text = nil
        self.imageView?.image = nil
        self.backgroundColor = .white
    }

    fileprivate func configureAutoLayout() {
        self.addSubview(self.iconImageView, anchors: [
            .leading(to: self.leadingAnchor, constant: 12),
            .centerY(to: self.centerYAnchor),
            .height(constant: 36),
            .width(constant: 36)
        ])

        self.addSubview(self.textLabel, anchors: [
            .leading(to: self.iconImageView.trailingAnchor, constant: 12),
            .centerY(to: self.centerYAnchor),
            .trailing(to: self.trailingAnchor, constant: 18)
        ])
        
        self.addSubview(self.chevronImageView, anchors: [
            .trailing(to: self.trailingAnchor, constant: 16),
            .centerY(to: self.centerYAnchor)
        ])
    }

}
