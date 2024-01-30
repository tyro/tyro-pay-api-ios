// The Swift Programming Language
// https://docs.swift.org/swift-book

#if !os(macOS)

import Foundation
import PassKit
import SwiftUI

#if DEBUG
import netfox
#endif

protocol ApplePayValidator {
  static func isApplePayAvailable() -> Bool
  static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool
}

public class TyroApplePay: NSObject, ApplePayValidator {
  internal let config: TyroApplePay.Configuration

  public init(config: TyroApplePay.Configuration) {
    self.config = config
    #if DEBUG
    NFX.sharedInstance().start()
    #endif
  }

  public static func isApplePayAvailable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  public static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: allowedCards)
  }
}

#endif
