//
//  SignUpTextFieldCell.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/07/2022.
//

import UIKit
import Resolver
import Combine

class SignUpTextFieldCell: UICollectionViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 20, weight: .black)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.font = .appFont(size: 17, weight: .semiBold)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        tf.tintColor = .black
        tf.autocorrectionType = .no
        return tf
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        return button
    }()

    @Injected
    var viewModel: SignInViewModelType

    var type: SignupTextFieldType?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.type = nil
        self.titleLabel.text = nil
        self.inputTextField.isSecureTextEntry = false
        self.inputTextField.keyboardType = .default
        self.textChanged()
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
        self.handleButtonState(active: false)
    }

    @objc fileprivate func handleNext() {
        guard let type = self.type, let text = self.inputTextField.text else { return }
        self.viewModel.currentPage.send(type.rawValue + 1)
        switch type {
            case .email: self.viewModel.email = text
            case .password: self.viewModel.password = text
            case .displayName:
                self.viewModel.displayName = text
                self.inputTextField.resignFirstResponder()
        }
    }

    @objc fileprivate func textChanged() {
        guard let type = self.type, let text = self.inputTextField.text else { return }
        switch type {
            case .email:
                text.contains("@") && text.contains(".") && text.count > 4 ? self.handleButtonState(active: true) : self.handleButtonState(active: false)
            case .password:
                text.count > 5 ? self.handleButtonState(active: true) : self.handleButtonState(active: false)
            case .displayName:
                text.count > 2 ? self.handleButtonState(active: true) : self.handleButtonState(active: false)
        }
    }

    fileprivate func handleButtonState(active: Bool) {
        self.nextButton.backgroundColor = active ? .primaryGreen : .secondaryBackgroundGray
        self.nextButton.setTitleColor(active ? .black : .inactiveTextGray, for: .normal)
        self.nextButton.isUserInteractionEnabled = active
    }

    func configureForEmail() {
        self.type = .email
        self.inputTextField.keyboardType = .emailAddress
        self.titleLabel.text = "Enter your email"
        self.inputTextField.isSecureTextEntry = false
        self.inputTextField.text = self.viewModel.email
    }

    func configureForPassword() {
        self.type = .password
        self.inputTextField.keyboardType = .default
        self.titleLabel.text = "Create a password"
        self.inputTextField.isSecureTextEntry = true
        self.inputTextField.text = self.viewModel.password
    }

    func configureForDisplayName() {
        self.type = .displayName
        self.inputTextField.keyboardType = .default
        self.titleLabel.text = "Pick a username"
        self.inputTextField.isSecureTextEntry = false
        self.inputTextField.text = self.viewModel.displayName
    }

    fileprivate func configureAutoLayout() {
        self.contentView.addSubview(self.titleLabel, anchors: [
            .top(to: self.topAnchor, constant: 30),
            .leading(to: self.leadingAnchor, constant: 20),
            .trailing(to: self.trailingAnchor, constant: 20)
        ])

        self.contentView.addSubview(self.nextButton, anchors: [
            .centerY(to: self.centerYAnchor, constant: 66),
            .leading(to: self.leadingAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        let helperView = UIView()
        helperView.isHidden = true
        
        self.contentView.addSubview(helperView, anchors: [
            .top(to: self.titleLabel.bottomAnchor),
            .bottom(to: self.nextButton.topAnchor),
            .centerX(to: self.centerXAnchor),
            .width(constant: 0)
        ])
        
        self.contentView.addSubview(self.inputTextField, anchors: [
            .centerY(to: helperView.centerYAnchor),
            .leading(to: self.leadingAnchor, constant: 12),
            .trailing(to: self.trailingAnchor, constant: 12),
            .height(constant: 30)
        ])
    }
}

enum SignupTextFieldType: Int {
    case email = 0
    case password = 1
    case displayName = 2
}
