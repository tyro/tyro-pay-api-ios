// The Swift Programming Language
// https://docs.swift.org/swift-book

#if os(iOS)

import Foundation
import PassKit
import SwiftUI

@objc protocol ApplePayValidator {
  static func isApplePayAvailable() -> Bool
  static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool
}

@objc public class TyroApplePay: NSObject, ApplePayValidator {
  internal let config: TyroApplePay.Configuration

  public init(config: TyroApplePay.Configuration) {
    self.config = config
  }

  public static func isApplePayAvailable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  public static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: allowedCards)
  }
}

#endif
