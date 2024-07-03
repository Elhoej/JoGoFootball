//
//  AutoLayoutDSL.swift
//  Bounty
//
//  Created by Simon Elhøj Steinmejer on 19/09/2021.
//

import UIKit

enum LayoutAnchor {
    case top(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case bottom(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case leading(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case trailing(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case centerX(to: NSLayoutXAxisAnchor, constant: CGFloat? = nil)
    case centerY(to: NSLayoutYAxisAnchor, constant: CGFloat? = nil)
    case height(constant: CGFloat)
    case heightAnchor(to: NSLayoutDimension)
    case width(constant: CGFloat)
    case widthAnchor(to: NSLayoutDimension)
    case size(CGSize)
    case fill(padding: UIEdgeInsets? = nil)
    case fillInSafeArea(padding: UIEdgeInsets? = nil)
    case centerInSuperview(rect: CGRect = .zero)
}

extension UIView {

    func addSubview(_ subview: UIView, anchors: [LayoutAnchor]) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        anchors.forEach { anchor in
            switch anchor {
                case .top(let anchor, let constant):
                    subview.topAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .bottom(let anchor, let constant):
                    subview.bottomAnchor.constraint(equalTo: anchor, constant: -(constant ?? 0)).isActive = true
                case .leading(let anchor, let constant):
                    subview.leadingAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .trailing(let anchor, let constant):
                    subview.trailingAnchor.constraint(equalTo: anchor, constant: -(constant ?? 0)).isActive = true
                case .centerX(let anchor, let constant):
                    subview.centerXAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .centerY(let anchor, let constant):
                    subview.centerYAnchor.constraint(equalTo: anchor, constant: constant ?? 0).isActive = true
                case .height(let constant):
                    subview.heightAnchor.constraint(equalToConstant: constant).isActive = true
                case .heightAnchor(to: let dimension):
                    subview.heightAnchor.constraint(equalTo: dimension).isActive = true
                case .width(let constant):
                    subview.widthAnchor.constraint(equalToConstant: constant).isActive = true
                case .widthAnchor(to: let dimension):
                    subview.widthAnchor.constraint(equalTo: dimension).isActive = true
                case .fill(padding: let padding):
                    subview.topAnchor.constraint(equalTo: self.topAnchor, constant: padding?.top ?? 0).isActive = true
                    subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding?.left ?? 0).isActive = true
                    subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(padding?.right ?? 0)).isActive = true
                    subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(padding?.bottom ?? 0)).isActive = true
                case .fillInSafeArea(padding: let padding):
                    subview.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: padding?.top ?? 0).isActive = true
                    subview.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: padding?.left ?? 0).isActive = true
                    subview.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -(padding?.right ?? 0)).isActive = true
                    subview.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -(padding?.bottom ?? 0)).isActive = true
                case .centerInSuperview(rect: let rect):
                    subview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: rect.origin.y).isActive = true
                    subview.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: rect.origin.x).isActive = true
                    subview.heightAnchor.constraint(equalToConstant: rect.height).isActive = true
                    subview.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
                case .size(let size):
                    subview.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                    subview.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            }
        }
    }
}
