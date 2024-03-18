// The Swift Programming Language
// https://docs.swift.org/swift-book

#if os(iOS)

import Foundation
import PassKit
import SwiftUI
import Factory

@objc protocol ApplePayValidator {
  static func isApplePayAvailable() -> Bool
  static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool
}

@objc public class TyroApplePay: NSObject, ApplePayValidator {
	internal let viewModel: PayRequestViewModel

  public init(config: TyroApplePay.Configuration) {
		self.viewModel = Container.shared.payRequestViewModel()
		self.viewModel.config = config
  }

  public static func isApplePayAvailable() -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments()
  }

  public static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool {
    return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: allowedCards)
  }

	public func startPayment(paySecret: String, paymentItems: [PaymentItem]) async throws -> TyroApplePay.Result {
		return try await self.viewModel.startPayment(paySecret: paySecret, paymentItems: paymentItems)
	}
}

#endif
