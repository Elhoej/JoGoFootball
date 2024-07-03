//
//  ProfileViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 20/07/2022.
//

import UIKit
import Resolver
import Combine
import Kingfisher
import ParseSwift
import SwiftUI

class ProfileViewController: UIViewController {

    lazy var avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(editAvatar), for: .touchUpInside)
        return button
    }()

    let avartarLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.font = .appFont(size: 15, weight: .medium)
        label.text = "Avatar"
        return label
    }()

    let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.masksToBounds = true
        return iv
    }()

    lazy var displayNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(editDisplayName), for: .touchUpInside)
        return button
    }()

    let displayNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.font = .appFont(size: 15, weight: .medium)
        label.text = "Display name"
        return label
    }()

    let displayNameValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .right
        label.font = .appFont(size: 15, weight: .medium)
        return label
    }()

    lazy var deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setTitle("Delete account", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(deleteAccountPrompt), for: .touchUpInside)
        return button
    }()

    @Injected
    var viewModel: SettingsViewModelType
    var hasAvatar = false
    var cancellables: Set<AnyCancellable> = []
    var coordinator: CoordinatorType!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .backgroundGray
        self.navigationItem.title = "User settings"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: Media.backIcon.image, style: .plain, target: self, action: #selector(back))
    }

    fileprivate func configureBindings() {
        self.viewModel.user
            .sink { [weak self] user in
                self?.displayNameValueLabel.text = user?.displayName
                if let imageUrl = user?.imageUrl {
                    self?.hasAvatar = true
                    self?.avatarImageView.kf.setImage(with: imageUrl)
                } else {
                    self?.hasAvatar = false
                    self?.avatarImageView.image = UIImage.initialsImage(name: user?.displayName ?? "?")
                }
            }
            .store(in: &cancellables)
    }

    @objc fileprivate func handleTextField(_ textField: UITextField) {
        self.displayNameAlert?.actions[0].isEnabled = (textField.text?.count ?? 0) > 2
    }

    var displayNameAlert: UIAlertController?

    @objc fileprivate func editDisplayName() {
        let alert = UIAlertController(title: "Enter a new display name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Display name..."
            textField.addTarget(self, action: #selector(self.handleTextField(_:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let newName = alert.textFields?[0].text else { return }
            self.saveDisplayName(newName)
        }))
        alert.actions[0].isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.displayNameAlert = alert
        self.present(alert, animated: true)
    }

    fileprivate func saveDisplayName(_ name: String) {
        self.displayNameAlert = nil
        guard var user = User.current else { return }
        user.displayName = name
        self.viewModel.saveUser(user: user)
            .sink { [weak self] completion in
                switch completion {
                    case .failure(let error):
                        self?.alert(message: error.message)
                    case .finished:
                        self?.alert(message: "Your display name has been updated")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    @objc fileprivate func editAvatar() {
        let alert = UIAlertController(title: "Select your avatar", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openImagePicker(type: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openImagePicker(type: .camera)
        }))
        //TODO: Needs permission to delete?
//        if self.hasAvatar {
//            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
//                self.selectImage(nil)
//            }))
//        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func openImagePicker(type: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Your \(type == .camera ? "camera" : "photo library") is unavailable", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func selectImage(_ image: UIImage?) {
        if let image = image {
            let resizedImage = image.resizeWithScaleAspectFitMode(to: 300)
            let imageData = resizedImage?.pngData() ?? image.jpegData(compressionQuality: 0.6)!
            guard var user = User.current else { return }
            let file = ParseFile(name: "\(user.id)-avatar", data: imageData)
            user.avatar = file
            self.viewModel.saveUser(user: user)
                .sink { [weak self] completion in
                    switch completion {
                        case .failure(let error):
                            self?.alert(message: error.message)
                        case .finished:
                            self?.alert(message: "Your avatar has been updated")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        } else {
            self.viewModel.deleteAvatar()
                .sink { [weak self] completion in
                    switch completion {
                        case .failure(let error):
                            self?.alert(message: error.message)
                        case .finished:
                            self?.alert(message: "Your avatar has been deleted")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }

    @objc fileprivate func deleteAccountPrompt() {
        let alert = UIAlertController(title: "Are you sure you want to delete your account? This action is irreversible", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

    fileprivate func deleteAccount() {
        self.viewModel.deleteUser()
            .sink { [weak self] completion in
                switch completion {
                    case .failure(let error):
                        self?.alert(message: error.message)
                    case .finished:
                        try? self?.coordinator.transition(to: AppTransition.signedOut)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.avatarButton, anchors: [
            .top(to: self.view.topAnchor, constant: 64),
            .leading(to: self.view.leadingAnchor, constant: 16),
            .trailing(to: self.view.trailingAnchor, constant: 16),
            .height(constant: 60)
        ])

        self.view.addSubview(self.avartarLabel, anchors: [
            .leading(to: self.avatarButton.leadingAnchor, constant: 16),
            .centerY(to: self.avatarButton.centerYAnchor)
        ])

        self.view.addSubview(self.avatarImageView, anchors: [
            .trailing(to: self.avatarButton.trailingAnchor, constant: 16),
            .centerY(to: self.avatarButton.centerYAnchor),
            .width(constant: 24),
            .height(constant: 24)
        ])

        self.view.addSubview(self.displayNameButton, anchors: [
            .top(to: self.avatarButton.bottomAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor, constant: 16),
            .trailing(to: self.view.trailingAnchor, constant: 16),
            .height(constant: 60)
        ])

        self.view.addSubview(self.displayNameLabel, anchors: [
            .leading(to: self.displayNameButton.leadingAnchor, constant: 16),
            .centerY(to: self.displayNameButton.centerYAnchor)
        ])

        self.view.addSubview(self.displayNameValueLabel, anchors: [
            .trailing(to: self.displayNameButton.trailingAnchor, constant: 16),
            .centerY(to: self.displayNameButton.centerYAnchor),
            .leading(to: self.displayNameLabel.trailingAnchor, constant: 12)
        ])

        self.view.addSubview(self.deleteAccountButton, anchors: [
            .bottom(to: self.view.bottomAnchor, constant: 60),
            .leading(to: self.view.leadingAnchor, constant: 16),
            .trailing(to: self.view.trailingAnchor, constant: 16),
            .height(constant: 60)
        ])
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.selectImage(editedImage)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectImage(image)
        }

        picker.dismiss(animated:true, completion: nil)
    }
}
