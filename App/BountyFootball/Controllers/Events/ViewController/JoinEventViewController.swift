//
//  JoinEventViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Combine
import Resolver

protocol JoinEventViewControllerDelegate: AnyObject {
    func didJoin(event: EventModel)
}

class JoinEventViewController: UIViewController {
    
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
        label.text = "Join event"
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.numberOfLines = 2
        label.text = "If you’re invited to an event, you can paste the invitation key here to join"
        return label
    }()
    
    let codeInputView = CodeInputView()
    
    lazy var joinButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.backgroundColor = .secondaryBackgroundGray
        button.setTitle("Join event", for: .normal)
        button.setTitleColor(.inactiveTextGray, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(join), for: .touchUpInside)
        return button
    }()
    
    @Injected
    var viewModel: JoinEventViewModelType
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: JoinEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
        self.configureAutoLayout()
    }
    
    @objc fileprivate func close() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func join() {
        guard let code = self.codeInputView.hiddenTextField.text?.uppercased() else { return }
        self.joinButton.isBusy = true
        self.viewModel.joinEvent(with: code)
            .sink { [weak self] completion in
                self?.joinButton.isBusy = false
                switch completion {
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Invalid code", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                        self?.present(alert, animated: true)
                    case .finished: break
                }
            } receiveValue: { event in
                NotificationCenter.default.post(name: .refreshEvents, object: self)
                self.dismiss(animated: true) {
                    self.delegate?.didJoin(event: event)
                }
            }
            .store(in: &self.cancellables)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        _ = self.codeInputView.becomeFirstResponder()
    }
    
    fileprivate func configureBindings() {
        self.codeInputView.textProperty
            .eraseToAnyPublisher()
            .map ({ $0?.count ?? 0 })
            .sink { count in
                self.joinButton.isEnabled = count == 6
                self.joinButton.backgroundColor = count == 6 ? .white : .secondaryBackgroundGray
            }
            .store(in: &self.cancellables)
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
        
        self.view.addSubview(self.joinButton, anchors: [
            .top(to: self.codeInputView.bottomAnchor, constant: 20),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
    }
}
