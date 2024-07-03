//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 23/2/2024.
//

#if os(iOS)

import Foundation

class PayRequestServiceFixtures {

  static let invalid = "{}"
	static var noVGSRoutePrefix = """
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

  static var success = """
  {
    "status": "SUCCESS",
    "vgsRoutePrefix": "vgsRoutePrefix",
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

  static var awaitingPaymentInput = """
  {
    "status": "AWAITING_PAYMENT_INPUT",
    "vgsRoutePrefix": "vgsRoutePrefix",
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
