//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Foundation
import PassKit

class PaymentTokenMock: PKPaymentToken {
  override var paymentData: Data {
    get { jsonString.data(using: .utf8)! }
  }

  var jsonString: String

  init(jsonString: String) {
    self.jsonString = jsonString
  }
}

class PaymentMock: PKPayment {

  override var token: PKPaymentToken {
    return self._token
  }

  let _token: PaymentTokenMock

  init(token: PaymentTokenMock) {
    self._token = token
  }
}

#endif
