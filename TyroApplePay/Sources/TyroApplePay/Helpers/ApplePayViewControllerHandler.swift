//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Foundation
import PassKit

class ApplePayViewControllerHandler {

  func presentController(delegate: PKPaymentAuthorizationControllerDelegate, paymentRequest: PKPaymentRequest) {

    let paymentController: PKPaymentAuthorizationController = PKPaymentAuthorizationController(
      paymentRequest: paymentRequest)
    paymentController.delegate = delegate
    paymentController.present()

  }

}

#endif
