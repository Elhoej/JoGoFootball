//
//  LoadingButton.swift
//  Hangout
//
//  Created by Simon Elhøj Steinmejer on 10/03/2022.
//

import UIKit

class LoadingButton: UIButton {

    var title: String?
    var image: UIImage?

    var isBusy = false {
        didSet {
            self.isUserInteractionEnabled = !self.isBusy
            self.isBusy ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
            if self.isBusy {
                self.title = self.title(for: .normal)
                self.image = self.image(for: .normal)
                super.setTitle("", for: UIControl.State())
                super.setImage(nil, for: UIControl.State())
            } else {
                self.setTitle(self.title, for: .normal)
                self.setImage(self.image, for: .normal)
            }
        }
    }

    let indicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.hidesWhenStopped = true
        return aiv
    }()

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.image = image
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        self.title = title
    }

    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        self.indicatorView.color = color
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    fileprivate func configure() {
        self.addSubview(self.indicatorView, anchors: [.centerInSuperview(rect: .zero)])
    }
}
