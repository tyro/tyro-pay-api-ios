//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if os(iOS)

import Foundation
import PassKit
@testable import TyroApplePay

class ApplePayViewControllerHandlerStub: ApplePayViewControllerHandler {

  let jsonString: String?

  init(jsonString: String? = nil) {
    self.jsonString = jsonString
  }

  override func presentController(delegate: PKPaymentAuthorizationControllerDelegate, paymentRequest: PKPaymentRequest) {
    let controller = PKPaymentAuthorizationController()
    guard let jsonString = self.jsonString else {
      delegate.paymentAuthorizationControllerDidFinish(controller)
      return
    }

    let mockedPayment = PaymentMock(token: PaymentTokenMock(jsonString: jsonString))

    delegate.paymentAuthorizationController?(controller, didAuthorizePayment: mockedPayment, handler: { result in
      delegate.paymentAuthorizationControllerDidFinish(controller)
    })
  }
}

#endif
