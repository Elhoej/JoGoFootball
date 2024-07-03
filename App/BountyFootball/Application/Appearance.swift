//
//  Appearance.swift
//  Hangout
//
//  Created by Simon Elhøj Steinmejer on 10/03/2022.
//

import UIKit

struct Appearance {

    static func configure() {
        //self.printFonts()
        self.configureNavigationBar()
    }

    static fileprivate func printFonts() {
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }

    static fileprivate func configureNavigationBar() {
        UIBarButtonItem.appearance().tintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.appFont(size: 15, weight: .medium)], for: .normal)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.appFont(size: 15, weight: .medium)
        ]
    }
}

enum FontWeight: String {
    case black
    case bold
    case extraBold
    case extraLight
    case light
    case medium
    case regular
    case semiBold
    case thin
}

extension UIFont {
    static func appFont(size: CGFloat, weight: FontWeight) -> UIFont {
        return UIFont(name: "Inter-\(weight.rawValue.capitalized)", size: size)!
    }
}

extension UIColor {
    static let primaryGreen = UIColor(red: 20/255, green: 250/255, blue: 85/255, alpha: 1.00)
    static let darkGreen = UIColor(red: 0.01, green: 0.53, blue: 0.30, alpha: 1.00)
    static let progressGray = UIColor(red: 0.88, green: 0.89, blue: 0.96, alpha: 1.00)
    static let textGray = UIColor(red: 0.35, green: 0.42, blue: 0.52, alpha: 1.00)
    static let borderGray = UIColor(red: 223/255, green: 228/255, blue: 244/255, alpha: 1.00)
    static let inactiveGray = UIColor(red: 223/255, green: 228/255, blue: 244/255, alpha: 1.00)
    static let inactiveTextGray = UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1.00)
    static let backgroundGray = UIColor(red: 230/255, green: 233/255, blue: 236/255, alpha: 1.00)
    static let secondaryBackgroundGray = UIColor(red: 243/255, green: 244/255, blue: 245/255, alpha: 1)
    static let dividerBackground = UIColor(red: 88/255, green: 109/255, blue: 132/255, alpha: 0.2)
    static let wrongRed = UIColor(red: 235/255, green: 187/255, blue: 187/255, alpha: 1)
    static let correctGreen = UIColor(red: 141/255, green: 255/255, blue: 173/255, alpha: 1)
}
