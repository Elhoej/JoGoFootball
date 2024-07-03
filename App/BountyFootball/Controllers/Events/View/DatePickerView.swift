//
//  DatePickerView.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import CombineCocoa

protocol DatePickerViewDelegate: AnyObject {
    func didSelectDate(_ date: Date, for type: DateType)
}

enum DateType {
    case start
    case finish
}

class DatePickerView: UIView {

    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = .black
        datePicker.backgroundColor = .white
        datePicker.layer.cornerRadius = 12
        datePicker.layer.masksToBounds = true
        datePicker.addTarget(self, action: #selector(handleDate), for: .valueChanged)
        return datePicker
    }()
    
    let tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: DatePickerViewDelegate?
    var type: DateType
    
    convenience init(minimumDate: Date, type: DateType) {
        self.init(frame: .zero)
        self.type = type
        self.datePicker.minimumDate = minimumDate
        self.configureView()
    }
    
    override init(frame: CGRect) {
        self.type = .start
        super.init(frame: frame)
        self.configureView()
        self.configureBindings()
        self.configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        self.type = .start
        super.init(coder: coder)
        self.configureView()
        self.configureBindings()
        self.configureAutoLayout()
    }
    
    @objc fileprivate func handleDate() {
        let selectedDate = self.datePicker.date
        self.delegate?.didSelectDate(selectedDate, for: self.type)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    fileprivate func configureView() {
        self.backgroundColor = .black.withAlphaComponent(0.7)
        self.clipsToBounds = true
        self.alpha = 0
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.tapGesture)
    }
    
    fileprivate func configureBindings() {
        self.tapGesture.tapPublisher.sink { [weak self] _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self?.alpha = 0
            } completion: { _ in
                self?.removeFromSuperview()
            }
        }
        .store(in: &self.cancellables)
    }
    
    fileprivate func configureAutoLayout() {
        let size = UIScreen.main.bounds.width - 32
        self.addSubview(self.datePicker, anchors: [
            .centerX(to: self.centerXAnchor),
            .centerY(to: self.centerYAnchor),
            .height(constant: size),
            .width(constant: size)
        ])
    }
}
