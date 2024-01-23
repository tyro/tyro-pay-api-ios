//
//  ContentView.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 23/1/2024.
//

import SwiftUI
import PassKit
import TyroApplePay

struct ContentView: View {
  @State private var paymentReady = TyroApplePay.applePayStatus().canMakePayments
  @State private var showPaymentViewSheet = false
  private let paymentHandler = TyroApplePay()
  
    var body: some View {
        VStack {
          PayWithApplePayButton  {
            print(paymentReady)
//            self.paymentHandler.startPayment { (success) in
//              if success {
//                print("Success")
//              } else {
//                print("Failed")
//              }
//            }
          }.opacity(paymentReady ? 1 : 0).scaledToFit()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
