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
	@State private var showAlert = false
	@State private var paymentCancelled = false
	@State private var paymentSuccessful = false
	@State private var paymentFailed = false
	@State private var error: Error?

	var body: some View {
		VStack {
			let paySecret = "$2a$10$GMAJw4hcZgLrniemEgL/gOFWy7DtspLQoF4678sN/foJx/3G4PHnG"
			let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
				merchantIdentifier: "merchant.tyro-pay-api-sample-app", // Your merchant id registered for the app on apple developer center
				allowedCardNetworks: [.visa, .masterCard]
			), layout: TyroApplePay.Layout(
				totalLabel: "MerchantName"
			))

			PayWithApplePayButton {
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
					} catch {
						showAlert = true
						paymentFailed = true
						self.error = error
					}
				}
			}
			.frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
			.alert(isPresented: ($showAlert)) {
				if paymentCancelled {
					return Alert(title: Text("Payment Cancelled"), message: Text("Payment was cancelled"), dismissButton: .default(Text("Ok")))
				}
				if paymentFailed {
					return Alert(title: Text("Payment Failed"), message: Text(self.error!.localizedDescription), dismissButton: .default(Text("Ok")))
				}
				return Alert(title: Text("Payment Successfull"), message: Text("Payment was successfull"), dismissButton: .default(Text("Ok")))
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
