//
//  SignUpViewController.swift
//  BountyFootball
//
//  Created by Simon Elhøj Steinmejer on 14/07/2022.
//

import UIKit
import Resolver
import Combine
import ParseSwift

class SignUpViewController: UIViewController {

    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Media.backIcon.image, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()

    var progressBarView: UIProgressView = {
        let pv = UIProgressView()
        pv.trackTintColor = .progressGray
        pv.progressTintColor = .black
        pv.layer.cornerRadius = 2
        pv.layer.masksToBounds = true
        pv.progress = 0.25
        return pv
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(cell: SignUpTextFieldCell.self)
        cv.register(cell: SignUpAvatarCell.self)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    lazy var signUpButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.setTitle("I'll upload avatar later", for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.titleLabel?.font = .appFont(size: 15, weight: .medium)
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    @Injected
    var viewModel: SignInViewModelType

    var cancellables: Set<AnyCancellable> = []
    var coordinator: CoordinatorType!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAutoLayout()
        self.configureView()
        self.configureBindings()
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .white
    }

    fileprivate func configureBindings() {
        self.viewModel.selectedImage
            .sink { [weak self] image in
                guard let self else { return }
                if image == nil {
                    self.signUpButton.setTitle("I'll upload avatar later", for: .normal)
                    self.signUpButton.layer.borderColor = UIColor.black.cgColor
                    self.signUpButton.layer.borderWidth = 1
                    self.signUpButton.backgroundColor = .white
                } else {
                    self.signUpButton.setTitle("Start predicting!", for: .normal)
                    self.signUpButton.layer.borderColor = UIColor.clear.cgColor
                    self.signUpButton.layer.borderWidth = 0
                    self.signUpButton.backgroundColor = .primaryGreen
                }
        }
        .store(in: &cancellables)

        self.viewModel.currentPage
            .sink { [weak self] page in
                guard let self else { return }
                let indexPath = IndexPath(item: page, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.view.layoutIfNeeded()
                let progress = ((Float(page) + 1.0) / 4.0)
                self.progressBarView.setProgress(progress, animated: true)
                self.signUpButton.isHidden = page != 3
        }
        .store(in: &cancellables)
    }

    @objc fileprivate func back() {
        if self.viewModel.currentPage.value != 0 {
            self.viewModel.currentPage.send(max(0, self.viewModel.currentPage.value - 1))
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc fileprivate func signUp() {
        guard let email = self.viewModel.email, let password = self.viewModel.password, let displayName = self.viewModel.displayName else { return }
        var user = User()
        user.email = email.lowercased()
        user.username = email.lowercased()
        user.password = password
        user.displayName = displayName

        var imageData: Data?

        if let image = self.viewModel.selectedImage.value {
            let resizedImage = image.resizeWithScaleAspectFitMode(to: 300)
            imageData = resizedImage?.pngData() ?? image.jpegData(compressionQuality: 0.6)
        }

        self.viewModel.signUp(user: user, imageData: imageData)
            .receive(on: RunLoop.main)
            .handleEvents { [weak self] _ in
                self?.signUpButton.isBusy = false
            } receiveRequest: { [weak self] _ in
                self?.signUpButton.isBusy = true
            }
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

    fileprivate func selectImage(_ image: UIImage?) {
        self.viewModel.selectedImage.send(image)
    }

    fileprivate func configureAutoLayout() {
        self.view.addSubview(self.backButton, anchors: [
            .top(to: self.view.topAnchor, constant: 48),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .height(constant: 30),
            .width(constant: 30)
        ])

        self.view.addSubview(self.progressBarView, anchors: [
            .centerY(to: self.backButton.centerYAnchor),
            .centerX(to: self.view.centerXAnchor),
            .height(constant: 4),
            .width(constant: 160)
        ])

        self.view.addSubview(self.signUpButton, anchors: [
            .bottom(to: self.view.bottomAnchor, constant: 50),
            .leading(to: self.view.leadingAnchor, constant: 12),
            .trailing(to: self.view.trailingAnchor, constant: 12),
            .height(constant: 60)
        ])

        self.view.addSubview(self.collectionView, anchors: [
            .top(to: self.backButton.bottomAnchor, constant: 12),
            .leading(to: self.view.leadingAnchor),
            .trailing(to: self.view.trailingAnchor),
            .bottom(to: self.signUpButton.topAnchor, constant: 12)
        ])
    }

    deinit { debugPrint("deinit \(self)") }
}

extension SignUpViewController: SignUpAvatarCellDelegate {
    func chooseAvatar() {
        let alert = UIAlertController(title: "Select your avatar", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openImagePicker(type: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openImagePicker(type: .camera)
        }))
        if self.viewModel.selectedImage.value != nil {
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
                self.selectImage(nil)
            }))
        }
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
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.selectImage(editedImage)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectImage(image)
        }

        picker.dismiss(animated:true, completion: nil)
    }
}

extension SignUpViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 3 {
            let cell = collectionView.dequeue(cell: SignUpAvatarCell.self, for: indexPath)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeue(cell: SignUpTextFieldCell.self, for: indexPath)
            switch indexPath.item {
                case 0: cell.configureForEmail()
                case 1: cell.configureForPassword()
                case 2: cell.configureForDisplayName()
                default: return UICollectionViewCell()
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SignUpTextFieldCell {
            cell.inputTextField.becomeFirstResponder()
        } else {
            self.viewModel.selectedImage.send(self.viewModel.selectedImage.value)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
