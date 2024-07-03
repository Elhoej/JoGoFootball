//
//  DeadlineCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 23/08/2023.
//

import UIKit

class DeadlineCell: UICollectionViewCell {
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .borderGray
        pv.progressTintColor = .black
        pv.layer.cornerRadius = 1.75
        pv.layer.masksToBounds = true
        return pv
    }()
    
    let timeRemainingLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd, yyyy"
        return df
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    func configure(with deadline: DeadlineModel) {
        self.dateLabel.text = self.dateFormatter.string(from: deadline.date)
        self.progressView.progress = deadline.progress
        self.timeRemainingLabel.text = deadline.remaining
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.addSubview(self.dateLabel, anchors: [
            .top(to: self.topAnchor, constant: 16),
            .leading(to: self.leadingAnchor, constant: 16)
        ])
        
        self.addSubview(self.progressView, anchors: [
            .bottom(to: self.bottomAnchor, constant: 16),
            .leading(to: self.leadingAnchor, constant: 16),
            .height(constant: 3.5),
            .width(constant: 160)
        ])
        
        self.addSubview(self.timeRemainingLabel, anchors: [
            .centerY(to: self.centerYAnchor),
            .trailing(to: self.trailingAnchor, constant: 16)
        ])
    }
    
}
