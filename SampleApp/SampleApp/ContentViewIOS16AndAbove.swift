//
//  ContentView.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 25/1/2024.
//

import TyroApplePay
import SwiftUI
import PassKit

@available(iOS 16, *)
struct ContentViewIOS16AndAbove: View {

	@State private var paymentSuccessful = false
	@State private var paymentFailed = false

	var body: some View {
		VStack {
			let paySecret = "$2a$10$gQHbFF7jbPqgfoRbTzyF.OrQtaOmZ2WYpkxKjdjhBmpE2iYBd9qoC"
			let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
				merchantIdentifier: "merchant.tyro-pay-api-sample-app", // Your merchant id registered for the app on apple developer center
				allowedCardNetworks: [.visa, .masterCard]
			))

			PayWithApplePayButton {
				Task.detached { @MainActor in
					do {
						let result = try await tyroApplePay.startPayment(paySecret: paySecret)

						switch result {
						case .cancelled:
							print("Sample App -> ContentView -> ApplePay cancelled")
						case .success:
							paymentSuccessful = true
							print("Sample App -> ContentView -> payment successful")
						}
					} catch is TyroApplePayError {
						paymentFailed = true
					}
				}
			}
			.frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
			.alert(isPresented: $paymentSuccessful) {
				Alert(title: Text("Payment Request"), message: Text("Payment was successful"), dismissButton: .default(Text("Ok")))
			}
			.alert(isPresented: ($paymentFailed)) {
				return Alert(title: Text("Payment Failed"), message: Text("Payment Failed"), dismissButton: .default(Text("Ok")))
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
