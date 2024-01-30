//
//  TyroApplePaybutton.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

#if !os(macOS)

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

public struct TyroApplePayButton: View {
  var paySecret: String
  var tyroApplePay: TyroApplePay
  var delegate: TyroApplePayButtonDelegate
  var paymentItems: [PaymentItem]
  @State private var isPresented: Bool = false
  @Environment(\.dismiss) var dismiss

  let viewModel: PayRequestViewModel = Container.shared.payRequestViewModel()

  // Find a better way to request and pass these parameters around
  public init(paySecret: String,
              paymentItems: [PaymentItem],
              tyroApplePay: TyroApplePay,
              delegate: TyroApplePayButtonDelegate) {
    self.paySecret = paySecret
    self.paymentItems = paymentItems
    self.delegate = delegate
    self.tyroApplePay = tyroApplePay
  }

  public var body: some View {
    PayWithApplePayButton {

      viewModel.config = self.tyroApplePay.config
      do {
        try viewModel.startPayment(paySecret: self.paySecret, paymentItems: self.paymentItems) { result in
          self.delegate.onPaymentResult(result: result)
          dismiss()
        }
      } catch {
        self.delegate.onPaymentResult(result: .error(TyroApplePayError.failedWith(error)))
        dismiss()
      }

    }.frame(width: 300, height: 100).opacity(TyroApplePay.isApplePayAvailable() ? 1 : 0)
  }
}

extension TyroApplePayButton: TyroApplePayButtonDelegate {
  public func onPaymentResult(result: TyroApplePay.Result) {
    self.delegate.onPaymentResult(result: result)
  }
}

#endif
