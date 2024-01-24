// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PassKit
import SwiftUI


public typealias PaymentCompletionHandler = (Bool) -> Void

public class TyroApplePay: NSObject {
  
  var completionHandler: PaymentCompletionHandler?

  static let supportedNetworks: [PKPaymentNetwork] = [
    .masterCard,
    .visa,
    .amex,
    .discover
  ]
  
  public static func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
    return (PKPaymentAuthorizationViewController.canMakePayments(),
            PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks))
  }
  
//  public func startPayment(completion: @escaping PaymentCompletionHandler) {
//    
//    completionHandler = completion
//    
//    let ticket = PKPaymentSummaryItem(label: "Festival Ticket", amount: NSDecimalNumber(string: "9.99"), type: .final)
//    let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
//    let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "10.99"), type: .final)
//    var paymentSummaryItems = [PKPaymentSummaryItem]()
//    paymentSummaryItems = [ticket, tax, total]
//    
//    let paymentRequest = PKPaymentRequest()
//    paymentRequest.paymentSummaryItems = paymentSummaryItems
//    paymentRequest.merchantIdentifier = Configuration.Merchant.identifier
//    paymentRequest.merchantCapabilities = [.credit]
//    paymentRequest.countryCode = "AU"
//    paymentRequest.currencyCode = "AUD"
//    paymentRequest.supportedNetworks = TyroApplePay.supportedNetworks
//    //    paymentRequest.shippingType = .delivery
//    //    paymentRequest.shippingMethods
//    //    paymentRequest.require
//    
//    let paymentController: PKPaymentAuthorizationController? = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
//    paymentController?.delegate = self
//    paymentController?.present(completion: { (presented: Bool) in
//      if presented {
//        print("Presented payment controller")
//      } else {
//        print("Failed to present payment controller")
//      }
//    })
//
//  }
  
}

//extension TyroApplePay: PKPaymentAuthorizationControllerDelegate {
//  
//  public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
//    completion(PKPaymentAuthorizationStatus.success)
//  }
//  
//  public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
//    controller.dismiss {
//      DispatchQueue.main.async {
//        self.completionHandler!(true)
//      }
//    }
//  }
//  
//  public func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
//    return nil
//  }
//  
//}
