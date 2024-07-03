//
//  EventCodeView.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 02/11/2023.
//

import UIKit
import Combine
import CombineCocoa

class CodeInputView: UIView {
    
    let code1TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let code2TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let code3TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let code4TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let code5TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let code6TextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderColor = UIColor.dividerBackground.cgColor
        tf.layer.borderWidth = 1
        tf.layer.masksToBounds = true
        tf.font = .appFont(size: 15, weight: .medium)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.tintColor = .black
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [self.code1TextField, self.code2TextField, self.code3TextField, self.code4TextField, self.code5TextField, self.code6TextField])
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.axis = .horizontal
//        sv.isUserInteractionEnabled = true
//        sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        return sv
    }()
    
    lazy var hiddenTextField: UITextField = {
        let tf = UITextField()
        tf.isHidden = true
        tf.delegate = self
        return tf
    }()
    
    var textProperty: AnyPublisher<String?, Never>!
    var cancellables: Set<AnyCancellable> = []
    var overrideText: String? {
        didSet {
            guard let overrideText = self.overrideText, !overrideText.isEmpty else { return }
            for (index, char) in overrideText.enumerated() {
                switch index {
                    case 0: self.code1TextField.text = String(char)
                    case 1: self.code2TextField.text = String(char)
                    case 2: self.code3TextField.text = String(char)
                    case 3: self.code4TextField.text = String(char)
                    case 4: self.code5TextField.text = String(char)
                    case 5: self.code6TextField.text = String(char)
                    default: break
                }
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return self.hiddenTextField.becomeFirstResponder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
        self.configureBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
        self.configureBindings()
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .clear
        
        self.addSubview(self.hiddenTextField, anchors: [
            .centerInSuperview()
        ])
        
        self.addSubview(self.stackView, anchors: [
            .fill()
        ])
    }
    
    fileprivate func configureBindings() {
        self.textProperty = self.hiddenTextField.textPublisher
        
        self.code1TextField
            .configure(property: self.textProperty, index: 0)
            .store(in: &self.cancellables)
        
        self.code2TextField
            .configure(property: self.textProperty, index: 1)
            .store(in: &self.cancellables)
        
        self.code3TextField
            .configure(property: self.textProperty, index: 2)
            .store(in: &self.cancellables)
        
        self.code4TextField
            .configure(property: self.textProperty, index: 3)
            .store(in: &self.cancellables)
        
        self.code5TextField
            .configure(property: self.textProperty, index: 4)
            .store(in: &self.cancellables)
        
        self.code6TextField
            .configure(property: self.textProperty, index: 5)
            .store(in: &self.cancellables)
    }
    
//    @objc fileprivate func handleTap() {
//        _ = self.becomeFirstResponder()
//    }
}

extension CodeInputView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        } else if (textField.text?.count ?? 0) >= 6 {
            return false
        } else {
            return true
        }
    }
}

fileprivate extension UITextField {
    func configure(property: AnyPublisher<String?, Never>, index: Int) -> AnyCancellable {
        return property.map { text -> String in
            guard let text = text, let char = Array(text)[safe: index] else { return "" }
            return String(char)
        }
        .scan(("", "")) { ($0.1, $1) }
        .sink { [weak self] events in
            let previous = events.0
            let newValue = events.1
            if previous.isEmpty && newValue.count == 1 {
                self?.text = newValue.uppercased()
            } else if previous.count == 1 && newValue.isEmpty {
                self?.text = ""
            }
        }
    }
}
