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

  @State private var paymentSuccessful = false

  var body: some View {
    VStack {
      let paySecret = "$2a$10$RAGdArKtXD8/WlWUVfs55uZmw1iN6o9Sfalbw0whlfdvABUKjwpsK"
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
                         tyroApplePay: tyroApplePay) { result in
        switch result {
        case .cancelled:
          print("Sample App -> ContentView -> ApplePay cancelled")
        case .success:
          paymentSuccessful = true
          print("Sample App -> ContentView -> payment successful")
        case .error(let error):
          print(error)
        }
      }
        .frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
        .alert(isPresented: $paymentSuccessful) {
          Alert(title: Text("Payment Request"), message: Text("Payment was successful"), dismissButton: .default(Text("Ok")))
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.blue)
  }
}

#Preview {
    ContentView()
}
