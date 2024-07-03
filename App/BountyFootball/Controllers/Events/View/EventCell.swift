//
//  EventCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import Kingfisher

class EventCell: UICollectionViewCell {
    
    let eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let eventTypeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.globalIcon.image
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    let eventNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .appFont(size: 15, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .white.withAlphaComponent(0.3)
        pv.progressTintColor = .white
        pv.layer.cornerRadius = 1
        pv.layer.masksToBounds = true
        return pv
    }()
    
    let finishedLabel: UILabel = {
        let label = UILabel()
        label.text = "Finished"
        label.font = .appFont(size: 12, weight: .regular)
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.eventImageView.bounds
        if self.eventImageView.layer.sublayers?.isEmpty ?? true {
            self.eventImageView.layer.addSublayer(gradientLayer)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.eventImageView.kf.cancelDownloadTask()
        self.eventImageView.image = nil
        self.eventNameLabel.text = nil
        self.progressView.progress = 0.0
        self.eventTypeImageView.isHidden = true
        self.progressView.isHidden = false
        self.finishedLabel.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
        self.configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
        self.configureAutoLayout()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
    func configure(for event: EventModel) {
        self.eventNameLabel.text = event.name
        self.eventImageView.kf.setImage(with: event.eventImage?.url)
        self.eventTypeImageView.isHidden = event.eventType != .global
        
        let start = Float(event.startTimestamp ?? 0)
        let end = Float(event.endTimestamp ?? 0)
        let now = Float(Date().timeIntervalSince1970)
        let progress = (now - start) / (end - start)
        
        if event.finished ?? false {
            self.progressView.isHidden = true
            self.finishedLabel.isHidden = false
        } else {
            UIView.animate(withDuration: 0.3) {
                self.progressView.progress = progress
            }
        }
    }
    
    fileprivate func configureAutoLayout() {
        
        self.addSubview(self.eventImageView, anchors: [
            .fill()
        ])
        
        self.addSubview(self.eventTypeImageView, anchors: [
            .top(to: self.topAnchor, constant: 10),
            .leading(to: self.leadingAnchor, constant: 10),
            .height(constant: 24),
            .width(constant: 24)
        ])
        
        self.addSubview(self.progressView, anchors: [
            .bottom(to: self.bottomAnchor, constant: 18),
            .leading(to: self.leadingAnchor, constant: 10),
            .trailing(to: self.trailingAnchor, constant: 10),
            .height(constant: 2)
        ])
        
        self.addSubview(self.finishedLabel, anchors: [
            .bottom(to: self.bottomAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 10)
        ])
        
        self.addSubview(self.eventNameLabel, anchors: [
            .bottom(to: self.progressView.topAnchor, constant: 12),
            .leading(to: self.leadingAnchor, constant: 10),
            .trailing(to: self.trailingAnchor, constant: 10)
        ])
    }
    
}

