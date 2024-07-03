// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Media {
  internal static let addIcon = ImageAsset(name: "add_icon")
  internal static let backIcon = ImageAsset(name: "back_icon")
  internal static let checkmarkIcon = ImageAsset(name: "checkmark_icon")
  internal static let checkmarkSelected = ImageAsset(name: "checkmark_selected")
  internal static let checkmarkUnselected = ImageAsset(name: "checkmark_unselected")
  internal static let chevronRightIcon = ImageAsset(name: "chevron_right_icon")
  internal static let drawImage = ImageAsset(name: "draw_image")
  internal static let editProfileIcon = ImageAsset(name: "edit_profile_icon")
  internal static let emptyPredictImage = ImageAsset(name: "empty_predict_image")
  internal static let filterIcon = ImageAsset(name: "filter_icon")
  internal static let globalIcon = ImageAsset(name: "global_icon")
  internal static let jogoLogo = ImageAsset(name: "jogo_logo")
  internal static let learnIcon = ImageAsset(name: "learn_icon")
  internal static let moreIcon = ImageAsset(name: "more_icon")
  internal static let notificationIcon = ImageAsset(name: "notification_icon")
  internal static let rateIcon = ImageAsset(name: "rate_icon")
  internal static let shareIcon = ImageAsset(name: "share_icon")
  internal static let signoutIcon = ImageAsset(name: "signout_icon")
  internal static let splashIcon = ImageAsset(name: "splash_icon")
  internal static let tabEventsActive = ImageAsset(name: "tab_events_active")
  internal static let tabEventsInactive = ImageAsset(name: "tab_events_inactive")
  internal static let tabPredictActive = ImageAsset(name: "tab_predict_active")
  internal static let tabPredictInactive = ImageAsset(name: "tab_predict_inactive")
  internal static let termsIcon = ImageAsset(name: "terms_icon")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
