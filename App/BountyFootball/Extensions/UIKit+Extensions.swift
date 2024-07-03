//
//  UIKit+Extensions.swift
//  Hangout
//
//  Created by Simon Elhøj Steinmejer on 09/03/2022.
//

import UIKit

extension UIViewController {
    var safeAreaTopPadding: CGFloat {
        let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
        return window?.safeAreaInsets.top ?? 0
    }

    func alert(message: String) {
        let alert = UIAlertController(title: "\(message)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        self.present(alert, animated: true)
    }
}

extension UIView {
    var safeAreaHeight: CGFloat {
        if #available(iOS 11, *) {
         return safeAreaLayoutGuide.layoutFrame.size.height
        }
        return bounds.height
    }

    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func gradientBorder(width: CGFloat, colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0), cornerRadius: CGFloat = 0) {

        let existingBorder = self.gradientBorderLayer()
        let border = existingBorder ?? CAGradientLayer()
        border.name = UIView.kLayerNameGradientBorder
        border.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + width, height: bounds.size.height + width)
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        let maskRect = CGRect(x: bounds.origin.x + width / 2, y: bounds.origin.y + width / 2, width: bounds.size.width - width, height: bounds.size.height - width)
        mask.path = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let exists = (existingBorder != nil)
        if !exists {
            self.layer.addSublayer(border)
        }
    }
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
    
    func parentView<T: UIView>(ofType: T.Type) -> T? {
        let parentView: UIView? = self.superview
        while parentView != nil {
            if let parentView = parentView as? T {
                return parentView
            } else {
                return self.parentView(ofType: ofType)
            }
        }
        return nil
    }
}

extension UICollectionViewCell {
    public class override var identifier: String { return String(describing: self) }
}

public extension UICollectionReusableView {
    @objc class var identifier: String { return String(describing: self) }
}

extension UICollectionView {

    func register<T: UICollectionViewCell>(cell: T.Type) {
        self.register(cell, forCellWithReuseIdentifier: cell.identifier)
    }

    func dequeue<T: UICollectionViewCell>(cell: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! T
    }
    
    func register<T: UICollectionReusableView>(supplementaryView: T.Type, type: SupplementaryViewType) {
        self.register(supplementaryView, forSupplementaryViewOfKind: type.kind, withReuseIdentifier: supplementaryView.identifier)
    }
    
    func dequeue<T: UICollectionReusableView>(supplementaryView: T.Type, type: SupplementaryViewType, for indexPath: IndexPath) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: type.kind, withReuseIdentifier: supplementaryView.identifier, for: indexPath) as! T
    }
}

public enum SupplementaryViewType {

    case header, footer

    var kind: String {
        switch self {
            case .header: return UICollectionView.elementKindSectionHeader
            case .footer: return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UITableViewCell {
    class var identifier: String { return String(describing: self) }
}

extension UITableViewHeaderFooterView {
    class var identifier: String { return String(describing: self) }
}

extension UITableView {
    func register<T: UITableViewCell>(cell: T.Type) {
        self.register(cell, forCellReuseIdentifier: cell.identifier)
    }

    func dequeue<T: UITableViewCell>(cell: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
    }

    func register<T: UITableViewHeaderFooterView>(headerFooter: T.Type) {
        self.register(headerFooter, forHeaderFooterViewReuseIdentifier: headerFooter.identifier)
    }

    func dequeue<T: UITableViewHeaderFooterView>(headerFooter: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: headerFooter.identifier) as! T
    }
}

extension UIStackView {
    func safelyRemoveArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat) {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
        self.leftView = leftPaddingView
        self.rightView = rightPaddingView
        self.leftViewMode = .always
        self.rightViewMode = .always
    }
}

extension UIImage {

    static func initialsImage(name: String?, size: CGSize = CGSize(width: 40, height: 40), fontSize: CGFloat = 14) -> UIImage? {
        var nonOptionalName = name ?? "?"
        let names = nonOptionalName.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        var initials: String?
        if names.count > 1 {
            let firstNameInitial = names[0].first?.uppercased()
            let lastNameInitial = names[1].first?.uppercased()
            initials = "\(firstNameInitial ?? "")\(lastNameInitial ?? "")"
        } else {
            initials = nonOptionalName.first?.uppercased()
        }

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.text = initials
        label.backgroundColor = .primaryGreen
        label.font = UIFont.appFont(size: fontSize, weight: .black)
        label.textAlignment = .center
        label.textColor = .black

        let renderer = UIGraphicsImageRenderer(bounds: label.bounds)
        return renderer.image { rendererContext in
            label.layer.render(in: rendererContext.cgContext)
        }
    }

    func getFileSizeInfo(allowedUnits: ByteCountFormatter.Units = .useMB, countStyle: ByteCountFormatter.CountStyle = .memory, compressionQuality: CGFloat = 1.0) -> String? {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.countStyle = countStyle
        return getSizeInfo(formatter: formatter, compressionQuality: compressionQuality)
    }

    func getSizeInfo(formatter: ByteCountFormatter, compressionQuality: CGFloat = 1.0) -> String? {
        guard let imageData = jpegData(compressionQuality: compressionQuality) else { return nil }
        return formatter.string(fromByteCount: Int64(imageData.count))
    }

    func resizeWithScaleAspectFitMode(to dimension: CGFloat) -> UIImage? {

        if max(size.width, size.height) <= dimension { return self }

        var newSize: CGSize!
        let aspectRatio = size.width / size.height

        if aspectRatio > 1 {
            // Landscape image
            newSize = CGSize(width: dimension, height: dimension / aspectRatio)
        } else {
            // Portrait image
            newSize = CGSize(width: dimension * aspectRatio, height: dimension)
        }

        return self.resizeWithCoreGraphics(to: newSize)
    }

    private func resizeWithCoreGraphics(to newSize: CGSize) -> UIImage? {
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace else { return nil }

        let width = Int(newSize.width)
        let height = Int(newSize.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(cgImage, in: rect)

        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }
}
