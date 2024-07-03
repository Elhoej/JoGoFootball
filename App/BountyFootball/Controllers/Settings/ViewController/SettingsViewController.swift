//
//  ProfileViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 20/07/2022.
//

import UIKit
import Combine
import Resolver
import Kingfisher
import MessageUI

class SettingsViewController: UIViewController {

    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
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

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.numberOfLines = 2
        return label
    }()

    lazy var rateButton: SettingsButton = {
        let button = SettingsButton(type: .system)
        button.title = "Rate app"
        button.image = Media.rateIcon.image
        button.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
        return button
    }()
    
    lazy var feedbackButton: SettingsButton = {
        let button = SettingsButton(type: .system)
        button.title = "Send feedback"
        button.image = Media.shareIcon.image
        button.addTarget(self, action: #selector(feedback), for: .touchUpInside)
        return button
    }()
    
    lazy var howItWorksButton: SettingsButton = {
        let button = SettingsButton(type: .system)
        button.title = "How it works"
        button.image = Media.learnIcon.image
        button.addTarget(self, action: #selector(howItWorks), for: .touchUpInside)
        return button
    }()
    
    lazy var notificationButton: SettingsButton = {
        let button = SettingsButton(type: .system)
        button.title = "Notifications"
        button.image = Media.notificationIcon.image
        button.addTarget(self, action: #selector(notifications), for: .touchUpInside)
        return button
    }()
    
    lazy var termsButton: SettingsButton = {
        let button = SettingsButton(type: .system)
        button.title = "Terms of use"
        button.image = Media.termsIcon.image
        button.addTarget(self, action: #selector(terms), for: .touchUpInside)
        return button
    }()

    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = .secondaryBackgroundGray
        return button
    }()

    let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "JoGo"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .appFont(size: 17, weight: .semiBold)
        return label
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 12, weight: .regular)
        let versionString = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "??")"
        let buildNumberString = "\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "??")"
        label.text = "v \(versionString) (\(buildNumberString))"
        return label
    }()

    @Injected
    var viewModel: SettingsViewModelType
    var coordinator: CoordinatorType!
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
    }

    fileprivate func configureBindings() {
        self.viewModel.user
            .dropFirst()
            .sink { user in
                self.nameLabel.text = user?.displayName
                if let imageUrl = user?.imageUrl {
                    self.avatarButton.kf.setImage(with: imageUrl, for: .normal)
                } else {
                    self.avatarButton.setImage(UIImage.initialsImage(name: user?.displayName ?? "?", size: CGSize(width: 180, height: 180), fontSize: 70), for: .normal)
                }
            }
            .store(in: &cancellables)
    }

    @objc fileprivate func editProfile() {
        try? self.coordinator.transition(to: SettingsTransition.profile)
    }

    @objc fileprivate func rateApp() {
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id1629135515") else { return }
            UIApplication.shared.open(appStoreURL)
    }
    
    @objc fileprivate func howItWorks() {
        let url = URL(string: "https://www.jogofootball.com/faq")!
        UIApplication.shared.open(url)
    }

    @objc fileprivate func feedback() {
        let feedbackEmail = "contact@jogofootball.com"
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients([feedbackEmail])
            mailController.setSubject("Feedback")
            mailController.setMessageBody("My feedback for JoGo: ", isHTML: false)
            self.present(mailController, animated: true)
        } else {
            guard let url = URL(string: "mailto:\(feedbackEmail)") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @objc fileprivate func notifications() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    @objc fileprivate func terms() {
        let url = URL(string: "https://www.jogofootball.com/terms")!
        UIApplication.shared.open(url)
    }

    @objc fileprivate func logout() {
        User.logout { [weak self] _ in
            try? self?.coordinator.transition(to: AppTransition.signedOut)
        }
    }

    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }

    fileprivate func configureAutoLayout() {
        
        self.view.addSubview(self.scrollView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
        
        self.scrollView.addSubview(self.contentView, anchors: [.fill()])
        self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        let heightAnchor = self.contentView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        heightAnchor.priority = UILayoutPriority(249)
        heightAnchor.isActive = true
        
        self.contentView.addSubview(self.avatarButton, anchors: [
            .centerX(to: self.contentView.centerXAnchor),
            .top(to: self.contentView.topAnchor, constant: 42),
            .height(constant: 130),
            .width(constant: 130)
        ])

        self.contentView.addSubview(self.editImageView, anchors: [
            .leading(to: self.avatarButton.leadingAnchor),
            .bottom(to: self.avatarButton.bottomAnchor, constant: -6),
            .height(constant: 42),
            .width(constant: 42)
        ])

        self.contentView.addSubview(self.nameLabel, anchors: [
            .top(to: self.avatarButton.bottomAnchor, constant: 16),
            .leading(to: self.contentView.leadingAnchor, constant: 18),
            .trailing(to: self.contentView.trailingAnchor, constant: 18)
        ])

        let stackViewOne = UIStackView(arrangedSubviews: [self.rateButton, self.howItWorksButton, self.feedbackButton])
        stackViewOne.spacing = 1
        stackViewOne.axis = .vertical
        stackViewOne.distribution = .fillEqually
        stackViewOne.layer.cornerRadius = 12
        stackViewOne.clipsToBounds = true

        let stackViewTwo = UIStackView(arrangedSubviews: [self.notificationButton, self.termsButton])
        stackViewTwo.spacing = 1
        stackViewTwo.axis = .vertical
        stackViewTwo.distribution = .fillEqually
        stackViewTwo.layer.cornerRadius = 12
        stackViewTwo.clipsToBounds = true
        
        self.contentView.addSubview(stackViewOne, anchors: [
            .top(to: self.nameLabel.bottomAnchor, constant: 32),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 182)
        ])
        
        self.contentView.addSubview(stackViewTwo, anchors: [
            .top(to: stackViewOne.bottomAnchor, constant: 16),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 121)
        ])
        
        self.contentView.addSubview(self.logoutButton, anchors: [
            .top(to: stackViewTwo.bottomAnchor, constant: 16),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 44)
        ])

        self.contentView.addSubview(self.versionLabel, anchors: [
            .top(to: self.logoutButton.bottomAnchor, constant: 44),
            .bottom(to: self.contentView.bottomAnchor, constant: 12),
            .centerX(to: self.contentView.centerXAnchor)
        ])

        self.contentView.addSubview(self.logoLabel, anchors: [
            .bottom(to: self.versionLabel.topAnchor, constant: 6),
            .centerX(to: self.contentView.centerXAnchor)
        ])
    }

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
