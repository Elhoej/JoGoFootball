//
//  SignInViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 16/07/2022.
//

import UIKit
import ParseSwift
import Resolver
import Combine

class SignInViewController: UIViewController {

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
        label.text = "Sign in"
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
        return tf
    }()

    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = .appFont(size: 12, weight: .regular)
        label.textColor = .textGray
        return label
    }()

    lazy var passwordTextField: UITextField = {
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
        tf.isSecureTextEntry = true
        return tf
    }()

    lazy var signInButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        return button
    }()
    
    lazy var forgotPasswordButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(size: 12, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributedText = NSAttributedString(string: "I forgot my password", attributes: textAttributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        return button
    }()

    @Injected
    var viewModel: SignInViewModelType
    var cancellables: Set<AnyCancellable> = []
    var coordinator: CoordinatorType!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureAutoLayout()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .white
        self.handleButtonState(active: false)
    }

    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc fileprivate func textChanged() {
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }
        email.contains("@") && email.contains(".") && email.count > 4 && password.count > 5 ? self.handleButtonState(active: true) : self.handleButtonState(active: false)
    }

    fileprivate func handleButtonState(active: Bool) {
        self.signInButton.backgroundColor = active ? .primaryGreen : .secondaryBackgroundGray
        self.signInButton.setTitleColor(active ? .black : .inactiveTextGray, for: .normal)
        self.signInButton.isUserInteractionEnabled = active
    }

    @objc fileprivate func signIn() {
        guard let email = self.emailTextField.text?.lowercased(), let password = self.passwordTextField.text else { return }

        self.viewModel.signIn(email: email, password: password)
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.signInButton.isBusy = false
            }, receiveRequest: { [weak self] _ in
                self?.signInButton.isBusy = true
            })
            .sink { [weak self] completion in
                switch completion {
                    case .failure(let error):
                        self?.alert(message: error.message)
                    case .finished:
                        try? self?.coordinator.transition(to: AppTransition.signedIn)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    @objc fileprivate func forgotPassword() {
        try? self.coordinator.transition(to: SignInTransition.forgotPassword)
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

        self.view.addSubview(self.passwordLabel, anchors: [
            .top(to: self.emailTextField.bottomAnchor, constant: 24),
            .leading(to: self.view.leadingAnchor, constant: 12)
        ])

        self.view.addSubview(self.passwordTextField, anchors: [
            .top(to: self.passwordLabel.bottomAnchor, constant: 10),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])

        self.view.addSubview(self.signInButton, anchors: [
            .top(to: self.passwordTextField.bottomAnchor, constant: 24),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.view.addSubview(self.forgotPasswordButton, anchors: [
            .top(to: self.signInButton.bottomAnchor, constant: 16),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 30)
        ])
    }

    deinit { debugPrint("deinit \(self)") }
}
