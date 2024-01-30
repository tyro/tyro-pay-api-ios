//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Foundation
import PassKit
@testable import TyroApplePay

class ApplePayViewControllerHandlerStub: ApplePayViewControllerHandler {

  let jsonString: String

  init(jsonString: String) {
    self.jsonString = jsonString
  }

  override func presentController(delegate: PKPaymentAuthorizationControllerDelegate, paymentRequest: PKPaymentRequest) {
    let controller = PKPaymentAuthorizationController()
    let mockedPayment = PaymentMock(token: PaymentTokenMock(jsonString: self.jsonString))

    delegate.paymentAuthorizationController?(controller, didAuthorizePayment: mockedPayment, handler: { result in
      delegate.paymentAuthorizationControllerDidFinish(controller)
    })
  }
}

#endif
