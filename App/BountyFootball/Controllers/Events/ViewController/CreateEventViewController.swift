//
//  CreateEventViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 13/08/2023.
//

import UIKit
import Combine
import Resolver
import ParseSwift

class CreateEventViewController: UIViewController {
    
    let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundGray
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .appFont(size: 15, weight: .medium)
        label.text = "Create event"
        return label
    }()
    
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
    
    lazy var eventNameButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Your new event"))
        button.setTitle("Name", for: .normal)
        button.addTarget(self, action: #selector(chooseEventName), for: .touchUpInside)
        return button
    }()
    
    lazy var competitionsButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Pick"))
        button.setTitle("Competitions", for: .normal)
        button.addTarget(self, action: #selector(chooseCompetitions), for: .touchUpInside)
        return button
    }()
    
    lazy var eventStartDateButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Pick"))
        button.setTitle("Starts", for: .normal)
        button.addTarget(self, action: #selector(chooseStartDate), for: .touchUpInside)
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    lazy var eventFinishDateButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .text("Pick"))
        button.setTitle("Event ends", for: .normal)
        button.addTarget(self, action: #selector(chooseFinishDate), for: .touchUpInside)
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    lazy var eventImageButton: EventFieldButton = {
        let button = EventFieldButton(valueType: .image)
        button.setTitle("Event image", for: .normal)
        button.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        return button
    }()
    
//    lazy var eventTypeButton: EventFieldButton = {
//        let button = EventFieldButton(valueType: .switch)
//        button.setTitle("Who can join?", for: .normal)
//        button.addTarget(self, action: #selector(handleEventTypeSwitch), for: .touchUpInside)
//        return button
//    }()
    
    lazy var createEventButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.backgroundColor = .primaryGreen
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Create event", for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        return button
    }()
    
    @Injected
    var viewModel: EventsViewModelType
    var coordinator: CoordinatorType!
    var cancellables: Set<AnyCancellable> = []
    
    var startDate = Calendar.current.startOfDay(for: Date())
    var finishDate: Date?
    var imageData: Data?
    var selectedLeagues = [LeagueModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }
    
    @objc fileprivate func chooseEventName() {
        let alert = UIAlertController(title: "Event name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.tintColor = .darkGreen
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            self?.eventNameButton.inputText = alert.textFields?.first?.text
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc fileprivate func chooseCompetitions() {
        try? self.coordinator.transition(to: EventTransition.chooseCompetitions(presenter: self))
    }
    
    @objc fileprivate func chooseStartDate() {
//        self.handleDatePicker(minimumDate: Date(), type: .start)
    }
    
    @objc fileprivate func chooseFinishDate() {
        try? self.coordinator.transition(to: EventTransition.chooseDuration(presenter: self))
//        let minimumDate = Calendar.current.date(byAdding: .day, value: 7, to: self.startDate) ?? Date().addingTimeInterval(86400)
//        self.handleDatePicker(minimumDate: minimumDate, type: .finish)
    }
    
//    fileprivate func handleDatePicker(minimumDate: Date, type: DateType) {
//        let datePickerView = DatePickerView(minimumDate: minimumDate, type: type)
//        datePickerView.delegate = self
//        let keyWindow = UIApplication
//            .shared
//            .connectedScenes
//            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
//            .last { $0.isKeyWindow }
//        keyWindow?.addSubview(datePickerView, anchors: [.fill()])
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
//            datePickerView.alpha = 1
//        }
//    }
    
    @objc fileprivate func chooseImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Your  photo library is unavailable", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func selectImage(_ image: UIImage) {
        let resizedImage = image.resizeWithScaleAspectFitMode(to: 500)
        let imageData = resizedImage?.pngData() ?? image.jpegData(compressionQuality: 0.7)!
        self.imageData = imageData
        self.eventImageButton.checkmarkImageView.image = Media.checkmarkSelected.image
    }
    
    @objc fileprivate func handleEventTypeSwitch() {
        
    }
    
    @objc fileprivate func createEvent() {
        guard let eventName = self.eventNameButton.inputText, !self.selectedLeagues.isEmpty, let endDate = self.finishDate else {
            let alert = UIAlertController(title: "Your event must have a name, at least one competition and a finish date", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Understood!", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        
        self.createEventButton.isBusy = true
        self.viewModel.createEvent(name: eventName, selectedLeagues: self.selectedLeagues, startTimestamp: Int(self.startDate.timeIntervalSince1970), endTimestamp: Int(endDate.timeIntervalSince1970), imageData: self.imageData)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.createEventButton.isBusy = false
                    NotificationCenter.default.post(name: .refreshEvents, object: self)
                }
                print(completion)
            } receiveValue: { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.eventStartDateButton.inputText = "Today"
//        self.eventTypeButton.inputText = "Open"
    }
    
    fileprivate func configureBindings() {
        
    }
    
    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.topBarView, anchors: [
            .top(to: self.view.topAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .height(constant: 54)
        ])
        
        self.topBarView.addSubview(self.cancelButton, anchors: [
            .top(to: self.view.topAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 24),
            .width(constant: 52)
        ])
        
        self.topBarView.addSubview(self.titleLabel, anchors: [
            .centerY(to: self.cancelButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor)
        ])
        
        self.view.addSubview(self.scrollView, anchors: [
            .top(to: self.topBarView.bottomAnchor),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.view.bottomAnchor)
        ])
        
        self.scrollView.addSubview(self.contentView, anchors: [.fill()])
        self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        let heightAnchor = self.contentView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        heightAnchor.priority = UILayoutPriority(249)
        heightAnchor.isActive = true
        
        self.contentView.addSubview(self.eventNameButton, anchors: [
            .top(to: self.contentView.topAnchor, constant: 20),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.contentView.addSubview(self.competitionsButton, anchors: [
            .top(to: self.eventNameButton.bottomAnchor, constant: 24),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.contentView.addSubview(self.eventStartDateButton, anchors: [
            .top(to: self.competitionsButton.bottomAnchor, constant: 24),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.contentView.addSubview(self.eventFinishDateButton, anchors: [
            .top(to: self.eventStartDateButton.bottomAnchor, constant: 1),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
        self.contentView.addSubview(self.eventImageButton, anchors: [
            .top(to: self.eventFinishDateButton.bottomAnchor, constant: 24),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])
        
//        self.contentView.addSubview(self.eventTypeButton, anchors: [
//            .top(to: self.eventImageButton.bottomAnchor, constant: 24),
//            .leading(to: self.contentView.leadingAnchor, constant: 12),
//            .trailing(to: self.contentView.trailingAnchor, constant: 12),
//            .height(constant: 60)
//        ])
        
        self.contentView.addSubview(self.createEventButton, anchors: [
            .top(to: self.eventImageButton.bottomAnchor, constant: 80),
            .leading(to: self.contentView.leadingAnchor, constant: 12),
            .trailing(to: self.contentView.trailingAnchor, constant: 12),
            .bottom(to: self.contentView.bottomAnchor, constant: 50),
            .height(constant: 60)
        ])
    }
    
    @objc fileprivate func cancel() {
        self.dismiss(animated: true)
    }
    
}

extension CreateEventViewController: ChooseLeagueViewControllerDelegate {
    func didChoose(leagues: [LeagueModel]) {
        self.competitionsButton.inputText = "\(leagues.count) selected"
        self.selectedLeagues = leagues
    }
}

extension CreateEventViewController: EventDurationViewControllerDelegate {
    func didSelect(eventDuration: EventDuration) {
        self.eventFinishDateButton.inputText = eventDuration.rawValue
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let nextMidnight = calendar.startOfDay(for: tomorrow)
        switch eventDuration {
            case .short:
                let date = calendar.date(byAdding: .day, value: 3, to: nextMidnight)
                self.finishDate = date
            case .medium:
                let date = calendar.date(byAdding: .day, value: 7, to: nextMidnight)
                self.finishDate = date
            case .long:
                let date = calendar.date(byAdding: .month, value: 1, to: nextMidnight)
                self.finishDate = date
        }
    }
}

extension CreateEventViewController: DatePickerViewDelegate {
    func didSelectDate(_ date: Date, for type: DateType) {
        switch type {
            case .start:
                self.startDate = date
                self.finishDate = nil
                self.eventFinishDateButton.inputText = nil
                self.eventStartDateButton.inputText = Calendar.current.isDateInToday(date) ? "Today" : "In \(Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 1) days"
            case .finish:
                self.finishDate = date
                self.eventFinishDateButton.inputText = "In \(Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 1) days"
        }
    }
}

extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.selectImage(editedImage)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectImage(image)
        }

        picker.dismiss(animated:true, completion: nil)
    }
}
