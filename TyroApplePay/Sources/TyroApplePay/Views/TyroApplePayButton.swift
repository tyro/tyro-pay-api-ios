//
//  TyroApplePaybutton.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

#if os(iOS)

import Foundation
import SwiftUI
import PassKit
import Factory

public enum PaymentItem {
  case custom(String, NSDecimalNumber)
  case discount(NSDecimalNumber)
  case tax(NSDecimalNumber)

  func createPKPaymentSummaryItem() -> PKPaymentSummaryItem {
    switch self {
    case .tax(let value):
      PKPaymentSummaryItem(label: "Tax", amount: value)
    case .discount(let value):
      PKPaymentSummaryItem(label: "Discount", amount: value)
    case .custom(let label, let value):
      PKPaymentSummaryItem(label: label, amount: value)
    }
  }
}

public typealias TyroApplePayButtonAction = (TyroApplePay.Result) -> Void

public struct TyroApplePayButton: View {
  var paySecret: String
  var tyroApplePay: TyroApplePay
  var action: TyroApplePayButtonAction
  var paymentItems: [PaymentItem]
  @State private var isPresented: Bool = false
  @Environment(\.dismiss) var dismiss

  let viewModel: PayRequestViewModel = Container.shared.payRequestViewModel()

  // Find a better way to request and pass these parameters around
  public init(paySecret: String,
              paymentItems: [PaymentItem],
              tyroApplePay: TyroApplePay,
              action: @escaping TyroApplePayButtonAction) {
    self.paySecret = paySecret
    self.paymentItems = paymentItems
    self.action = action
    self.tyroApplePay = tyroApplePay
  }

  public var body: some View {
    PayWithApplePayButton {
      viewModel.config = self.tyroApplePay.config
      Task {
        let result = await viewModel.startPayment(paySecret: self.paySecret, paymentItems: self.paymentItems)
        self.action(result)
        dismiss()
      }
    }.frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
  }
}

#endif
