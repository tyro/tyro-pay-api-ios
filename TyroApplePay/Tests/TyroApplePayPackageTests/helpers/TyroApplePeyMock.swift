//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Foundation
import PassKit
@testable import TyroApplePay

class TyroApplePayMock: ApplePayValidator {

  static func reset() {
    TyroApplePayMock.values = [:]
  }

  enum MockProperty: String {
    case isApplePayAvailable, canSetupCard
  }

  private static var values: [MockProperty: Bool] = [:]

  static subscript(key: MockProperty) -> Bool? {
    set {
      TyroApplePayMock.values[key] = newValue
    }
    get {
      return TyroApplePayMock.values[key]
    }
  }

  static func isApplePayAvailable() -> Bool {
    return TyroApplePayMock[.isApplePayAvailable] ?? false
  }
  static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool {
    return TyroApplePayMock[.canSetupCard] ?? false
  }
}

#endif
