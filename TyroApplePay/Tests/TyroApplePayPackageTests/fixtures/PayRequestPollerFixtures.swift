//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if os(iOS)

import Foundation
@testable import TyroApplePay

class PayRequestPollerFixtures {

  static var badPayRequestResponse = "{}"

  static var payRequestSuccessResponse = """
  {
    "status": "SUCCESS",
    "total": {
      "amount": 350,
      "currency": "AUD"
    },
    "origin": {
      "name": "Demo Pay Request",
      "orderId": "09345294-53f2-415d-a3c2-021f861430e3"
    },
    "capture": {
      "method": "MANUAL"
    },
    "provider": {
      "name": "TYRO",
      "method": "CARD"
    }
  }
  """

  static var payRequestAwaitingPaymentInputResponse = """
  {
    "status": "AWAITING_PAYMENT_INPUT",
    "total": {
      "amount": 350,
      "currency": "AUD"
    },
    "origin": {
      "name": "Demo Pay Request",
      "orderId": "09345294-53f2-415d-a3c2-021f861430e3"
    },
    "capture": {
      "method": "MANUAL"
    },
    "provider": {
      "name": "TYRO",
      "method": "CARD"
    }
  }
  """

}

#endif
