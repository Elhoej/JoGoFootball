//
//  ForgotPasswordViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 18/11/2023.
//

import UIKit
import Resolver
import Combine

class ForgotPasswordViewController: UIViewController {
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Media.backIcon.image, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(size: 20, weight: .black)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Reset password"
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = .appFont(size: 12, weight: .regular)
        label.textColor = .textGray
        return label
    }()

    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.setPadding(left: 18, right: 18)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.borderGray.cgColor
        tf.layer.cornerRadius = 12
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        tf.tintColor = .black
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        return tf
    }()

    lazy var resetPasswordButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.setTitle("Reset my password", for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        return button
    }()
    
    @Injected
    var viewModel: SignInViewModelType
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureAutoLayout()
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .white
        self.handleButtonState(active: false)
        self.emailTextField.becomeFirstResponder()
    }
    
    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func resetPassword() {
        guard let email = self.emailTextField.text?.lowercased(), !email.isEmpty else { return }
        self.resetPasswordButton.isBusy = true
        self.viewModel.resetPassword(email: email)
            .sink { [weak self] completion in
                self?.resetPasswordButton.isBusy = false
                switch completion {
                    case .failure(let error):
                        let alert = UIAlertController(title: error.localizedDescription, message: error.message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default))
                        self?.present(alert, animated: true)
                    case .finished: break
                }
            } receiveValue: { [weak self] _ in
                let alert = UIAlertController(title: "We have sent you an email with further instructions", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true)
            }
            .store(in: &self.cancellables)
    }
    
    @objc fileprivate func textChanged() {
        guard let email = self.emailTextField.text else { return }
        email.contains("@") && email.contains(".") && email.count > 4 ? self.handleButtonState(active: true) : self.handleButtonState(active: false)
    }

    fileprivate func handleButtonState(active: Bool) {
        self.resetPasswordButton.backgroundColor = active ? .primaryGreen : .secondaryBackgroundGray
        self.resetPasswordButton.setTitleColor(active ? .black : .inactiveTextGray, for: .normal)
        self.resetPasswordButton.isUserInteractionEnabled = active
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.backButton, anchors: [
            .top(to: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 30),
            .width(constant: 30)
        ])

        self.view.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.backButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])

        self.view.addSubview(self.emailLabel, anchors: [
            .top(to: self.backButton.bottomAnchor, constant: 92),
            .leading(to: self.view.leadingAnchor, constant: 12)
        ])

        self.view.addSubview(self.emailTextField, anchors: [
            .top(to: self.emailLabel.bottomAnchor, constant: 10),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])

        self.view.addSubview(self.resetPasswordButton, anchors: [
            .top(to: self.emailTextField.bottomAnchor, constant: 24),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
    }
}
