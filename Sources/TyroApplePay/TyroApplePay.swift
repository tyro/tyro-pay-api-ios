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

	public init(config: TyroApplePay.Configuration, layout: TyroApplePay.Layout) {
		self.viewModel = Container.shared.payRequestViewModel()
		self.viewModel.config = config
		self.viewModel.layout = layout
  }

  public static func isApplePayAvailable() -> Bool {
    PKPaymentAuthorizationViewController.canMakePayments()
  }

  public static func canSetupCard(allowedCards: [PKPaymentNetwork]) -> Bool {
    PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: allowedCards)
  }

	public func startPayment(paySecret: String) async throws -> TyroApplePay.Result {
		try await self.viewModel.startPayment(paySecret: paySecret)
	}
}

#endif
