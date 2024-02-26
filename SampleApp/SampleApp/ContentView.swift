//
//  ContentView.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 25/1/2024.
//

import TyroApplePay
import SwiftUI
//import PassKit

struct ContentView: View {
  var body: some View {
    VStack {
      let paySecret = "paySecret"
      let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
        liveMode: false,
        merchantIdentifier: "merchant.tyro-pay-api-sample-app", // Your merchant id registered for the app on apple developer center
        allowedCardNetworks: [.visa, .masterCard]
      ))
      TyroApplePayButton(paySecret: paySecret,
                         paymentItems: [
                          .custom("Burger", NSDecimalNumber(string: "1.00")),
                          .custom("Total", NSDecimalNumber(string: "1.00"))
                         ],
                         tyroApplePay: tyroApplePay,
                         delegate: self)
        .frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.blue)
  }
}

extension ContentView: TyroApplePayButtonDelegate {
  func onPaymentResult(result: TyroApplePay.Result) {
    switch result {
    case .cancelled:
      print("Sample App -> ContentView -> ApplePay cancelled")
    case .success:
      print("Sample App -> ContentView -> payment successful")
    case .error(let error):
      print(error)
    }
  }
}

#Preview {
    ContentView()
}
