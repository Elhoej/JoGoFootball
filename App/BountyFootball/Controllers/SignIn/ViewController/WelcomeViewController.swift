//
//  ViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/07/2022.
//

import UIKit

class WelcomeViewController: UIViewController {

    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Media.jogoLogo.image
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let explanationLabel: UILabel = {
        let label = UILabel()
        label.text = "JoGo is a free-to-play,\nsocial prediction app.\n\nPredict football games to earn points. Correct predictions improve your rank.\n\nRank in Events, a group of friends, colleagues, fanclubs, families or something else."
        label.numberOfLines = 0
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .appFont(size: 17, weight: .semiBold)
        return label
    }()

    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return button
    }()

    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I already have an account", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        return button
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "By continuing, you agree to JoGo's"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 12, weight: .regular)
        return label
    }()
    
    lazy var termsButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedString = NSAttributedString(string: "Terms & Conditions", attributes: [
            .font: UIFont.appFont(size: 12, weight: .medium),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(termsAndConditions), for: .touchUpInside)
        return button
    }()

    var coordinator: CoordinatorType!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .primaryGreen
    }

    @objc fileprivate func signUp() {
        try? self.coordinator.transition(to: SignInTransition.signUp)
    }

    @objc fileprivate func signIn() {
        try? self.coordinator.transition(to: SignInTransition.signIn)
    }
    
    @objc fileprivate func termsAndConditions() {
        let url = URL(string: "https://www.jogofootball.com/terms")!
        UIApplication.shared.open(url)
    }

    fileprivate func configureAutoLayout() {
        
        self.view.addSubview(self.termsButton, anchors: [
            .bottom(to: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 12),
            .centerX(to: self.view.centerXAnchor),
        ])
        
        self.view.addSubview(self.termsLabel, anchors: [
            .bottom(to: self.termsButton.topAnchor, constant: 4),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.signInButton, anchors: [
            .bottom(to: self.termsLabel.topAnchor, constant: 16),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 50)
        ])
        
        self.view.addSubview(self.signUpButton, anchors: [
            .bottom(to: self.signInButton.topAnchor, constant: 16),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 50)
        ])
        
        self.view.addSubview(self.explanationLabel, anchors: [
            .leading(to: self.view.leadingAnchor, constant: 32),
            .trailing(to: self.view.trailingAnchor, constant: 32)
        ])
        self.explanationLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.signUpButton.topAnchor, constant: -110).isActive = true
        
        self.view.addSubview(self.logoImageView, anchors: [
            .bottom(to: self.explanationLabel.topAnchor, constant: 32),
            .centerX(to: self.view.centerXAnchor),
            .height(constant: 130),
            .width(constant: 130)
        ])
        self.logoImageView.topAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    }

    deinit { debugPrint("deinit \(self)") }
}

