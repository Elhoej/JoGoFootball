//
//  AttendeeStackView.swift
//  Hangout
//
//  Created by Simon Elhøj Steinmejer on 25/04/2022.
//

import UIKit
import Kingfisher

class AvatarStackView: UIStackView {

    lazy var additionalAttendeesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.font = FontFamily.Inter.regular.font(size: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: self.itemSize.width).isActive = true
        return label
    }()

    var maxWidth: CGFloat
    var itemSize: CGSize

    override init(frame: CGRect) {
        self.maxWidth = 0
        self.itemSize = .zero
        super.init(frame: frame)
        self.configureView()
    }

    required init(coder: NSCoder) {
        self.maxWidth = 0
        self.itemSize = .zero
        super.init(coder: coder)
        self.configureView()
    }

    required init(maxWidth: CGFloat, itemSize: CGSize) {
        self.maxWidth = maxWidth
        self.itemSize = itemSize
        super.init(frame: .zero)
        self.configureView()
    }

    fileprivate func configureView() {
        self.clipsToBounds = false
        self.spacing = -4
        self.axis = .horizontal
    }

    func configure(with users: [UserModel], host: UserModel?) {
        var mutableUsers = users
        if let host = host, let hostIndex = users.firstIndex(of: host) {
            mutableUsers.remove(at: hostIndex)
            let imageView = self.getImageView(for: host, host: true)
            imageView.layer.borderColor = UIColor.primaryGreen.cgColor
            self.addArrangedSubview(imageView)
        }

        for (index, user) in mutableUsers.enumerated() {

            if index > 2 {
                let currentCount = CGFloat(index) + 2.0
                let totalWidth = (self.itemSize.width * currentCount) + (self.spacing * CGFloat(index))
                if totalWidth > self.maxWidth {
                    let additionalAttendeeCount = users.count - self.arrangedSubviews.count
                    self.configureLabel(count: additionalAttendeeCount)
                    return
                }
            }

            let imageView = self.getImageView(for: user, host: false)
            self.addArrangedSubview(imageView)
        }
    }

    fileprivate func configureLabel(count: Int) {
        self.additionalAttendeesLabel.text = "+\(count)"
        self.addArrangedSubview(self.additionalAttendeesLabel)
    }

    fileprivate func getImageView(for user: UserModel, host: Bool) -> UIImageView {
        let imageView = UIImageView()
        imageView.kf.setImage(with: user.imageUrl, placeholder: UIImage.initialsImage(name: user.displayName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = self.itemSize.height / 2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: self.itemSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: self.itemSize.height).isActive = true
        return imageView
    }

    func reset() {
        self.additionalAttendeesLabel.isHidden = true
        self.safelyRemoveArrangedSubviews()
    }
}
