//
//  ContentViewBeforeIOS16.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 22/5/2024.
//

/**
 This example shows how to implement apple pay using the PKPaymentButton.
 This example use PKPaymentButton in SwiftUI but the knowledge here is replicable in case your application uses UIKit
 The PKPaymentButton is deprecated in iOS 16+ and should replaced with PayWithApplePayButton
 https://developer.apple.com/documentation/passkit_apple_pay_and_wallet/paywithapplepaybutton
 */

import TyroApplePay
import SwiftUI
import PassKit

@available(iOS, deprecated: 16, obsoleted: 16, message: "This example stills works in iOS 16+ but it is recommended to use the new PayWithApplePayButton")
struct ContentViewBeforeIOS16: View {
	@State private var showAlert = false
	@State private var paymentCancelled = false
	@State private var paymentSuccessful = false
	@State private var paymentFailed = false
	@State private var error: Error?

	var body: some View {
		VStack {
			let paySecret = "PAY REQUEST GOES HERE"
			let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
				merchantIdentifier: "merchant.tyro-pay-api-sample-app", // Your merchant id registered for the app on apple developer center
				allowedCardNetworks: [.visa, .masterCard]
			), layout: TyroApplePay.Layout(
				merchantName: "MerchantName"
			))

			PaymentButtonView {
				Task.detached { @MainActor in
					do {
						let result = try await tyroApplePay.startPayment(paySecret: paySecret)
						showAlert = true
						switch result {
						case .cancelled:
							paymentCancelled = true
							print("Sample App -> ContentView -> ApplePay cancelled")
						case .success:
							paymentSuccessful = true
							print("Sample App -> ContentView -> payment successful")
						}
					} catch is TyroApplePayError {
						showAlert = true
						paymentFailed = true
						self.error = error
					}
				}
			}
			.alert(isPresented: ($showAlert)) {
				if paymentCancelled {
					return Alert(title: Text("Payment Cancelled"), message: Text("Payment was cancelled"), dismissButton: .default(Text("Ok")))
				}
				if paymentFailed {
					return Alert(title: Text("Payment Failed"), message: Text(self.error!.localizedDescription), dismissButton: .default(Text("Ok")))
				}
				return Alert(title: Text("Payment Successfull"), message: Text("Payment was successfull"), dismissButton: .default(Text("Ok")))
			}
		}.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct PaymentButtonView: View {
	var action: () -> Void

	var height: CGFloat = 45

	var body: some View {
		ApplePayButtonForUIView(action: action)
			.frame(minWidth: 300, maxWidth: 100)
			.frame(height: height)
			.frame(maxWidth: .infinity)
	}

}

class Coordinator: NSObject {
	var action: () -> Void
	var button: PKPaymentButton = PKPaymentButton(paymentButtonType: PKPaymentButtonType.plain, paymentButtonStyle: PKPaymentButtonStyle.automatic)

	init(action: @escaping () -> Void) {
		self.action = action
		super.init()
		button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
	}

	@objc
	func callback(_ sender: Any) {
		action()
	}
}

struct ApplePayButtonForUIView: UIViewRepresentable {
	var action: () -> Void

	init(action: @escaping () -> Void) {
		self.action = action
	}

	func updateUIView(_ uiView: PKPaymentButton, context: Context) {
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(action: action)
	}

	func makeUIView(context: Context) -> UIView {
		context.coordinator.button
	}

	func updateUIView(_ rootView: UIView, context: Context) {
		context.coordinator.action = action
	}
}
