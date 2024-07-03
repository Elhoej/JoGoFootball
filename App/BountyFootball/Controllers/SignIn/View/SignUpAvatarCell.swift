//
//  SignUpAvatarCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 15/07/2022.
//

import UIKit
import Photos
import Resolver
import Combine

protocol SignUpAvatarCellDelegate: AnyObject {
    func chooseAvatar()
}

class SignUpAvatarCell: UICollectionViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 20, weight: .black)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Avatar"
        return label
    }()

    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 15, weight: .medium)
        label.textAlignment = .center
        label.textColor = .textGray
        label.text = "Upload an image"
        return label
    }()

    lazy var avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(chooseAvatar), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 65
        button.layer.masksToBounds = true
        button.imageView?.clipsToBounds = true
        return button
    }()

    let editImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.editProfileIcon.image
        return iv
    }()

    @Injected
    var viewModel: SignInViewModelType
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: SignUpAvatarCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
    }

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
        self.backgroundColor = .clear

        self.viewModel.selectedImage.sink { image in
            if let image = image {
                self.avatarButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                let initialsImage = UIImage.initialsImage(name: self.viewModel.displayName ?? "?", size: CGSize(width: 180, height: 180), fontSize: 70)
                self.avatarButton.setImage(initialsImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        .store(in: &cancellables)
    }

    @objc fileprivate func chooseAvatar() {
        self.delegate?.chooseAvatar()
    }

    fileprivate func configureAutoLayout() {
        self.contentView.addSubview(self.titleLabel, anchors: [
            .top(to: self.topAnchor, constant: 30),
            .leading(to: self.leadingAnchor, constant: 20),
            .trailing(to: self.trailingAnchor, constant: 20)
        ])

        self.contentView.addSubview(self.subTitleLabel, anchors: [
            .top(to: self.titleLabel.bottomAnchor, constant: 10),
            .leading(to: self.leadingAnchor, constant: 20),
            .trailing(to: self.trailingAnchor, constant: 20)
        ])

        self.contentView.addSubview(self.avatarButton, anchors: [
            .centerX(to: self.centerXAnchor),
            .centerY(to: self.centerYAnchor),
            .height(constant: 130),
            .width(constant: 130)
        ])

        self.contentView.addSubview(self.editImageView, anchors: [
            .leading(to: self.avatarButton.leadingAnchor),
            .bottom(to: self.avatarButton.bottomAnchor, constant: -6),
            .height(constant: 42),
            .width(constant: 42)
        ])
    }

}
