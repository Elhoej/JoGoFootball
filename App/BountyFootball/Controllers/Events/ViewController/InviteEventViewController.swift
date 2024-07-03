//
//  InviteEventViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Resolver

class CopiedView: UIView {

    let copiedLabel: UILabel = {
        let label = UILabel()
        label.text = "Copied to clipboard!"
        label.textColor = .black
        label.font = .appFont(size: 11, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .primaryGreen
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        self.addSubview(self.copiedLabel, anchors: [
            .centerY(to: self.centerYAnchor),
            .leading(to: self.leadingAnchor, constant: 16),
            .trailing(to: self.trailingAnchor, constant: 16)
        ])
    }
}

class InviteEventViewController: UIViewController {
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.text = "Add friends"
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.numberOfLines = 2
        label.text = "Provide others with this key, and they’ll be added to your event"
        return label
    }()
    
    lazy var codeInputView: CodeInputView = {
        let civ = CodeInputView()
        civ.isUserInteractionEnabled = true
        civ.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyCode)))
        return civ
    }()
    
    lazy var shareButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Share link", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(share), for: .touchUpInside)
        return button
    }()
    
    @Injected
    var viewModel: EventDetailViewModelType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureAutoLayout()
    }
    
    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func share() {
        guard let inviteCode = self.viewModel.event.inviteCode else { return }
        let invitationLink = "jogofootball://jogo.com/invitation?code=\(inviteCode)"
        let textToShare = [invitationLink]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc fileprivate func copyCode() {
        UIPasteboard.general.string = self.viewModel.event.inviteCode
        let view = CopiedView()
        view.alpha = 0
        self.view.addSubview(view, anchors: [
            .top(to: self.shareButton.bottomAnchor, constant: 20),
            .centerX(to: self.view.centerXAnchor),
            .height(constant: 30)
        ])
        
        UIView.animate(withDuration: 0.35) {
            view.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 1) {
                view.alpha = 0
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.codeInputView.overrideText = self.viewModel.event.inviteCode
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 54)
        ])
        
        self.topBarView.addSubview(self.closeButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.closeButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.bodyLabel, anchors: [
            .top(to: self.topBarView.bottomAnchor, constant: 45),
            .leading(to: self.view.leadingAnchor, constant: 30),
            .trailing(to: self.view.trailingAnchor, constant: 30)
        ])
        
        self.view.addSubview(self.codeInputView, anchors: [
            .top(to: self.bodyLabel.bottomAnchor, constant: 34),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.view.addSubview(self.shareButton, anchors: [
            .top(to: self.codeInputView.bottomAnchor, constant: 20),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
    }
}
