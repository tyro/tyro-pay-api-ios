//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

import Foundation
import PassKit

#if os(iOS)

public extension TyroApplePay {

  enum Constants: String, RawRepresentable {
    case payApiBaseUrl = "api.tyro.com"
    case payApiApplePaySandboxInboundBaseUrl = "pay-api-sample-app.pay.inbound.sandbox.applepay.connect.tyro.com"
    case payPaiApplePayLiveInboundBaseUrl = "pay-api-sample-app.pay.inbound.applepay.connect.tyro.com"
  }

  struct Configuration {
    let merchantIdentifier: String
    let countryCode: String
    let currencyCode: String
    let allowedCardNetworks: [PKPaymentNetwork]

    public init(merchantIdentifier: String,
                allowedCardNetworks: [PKPaymentNetwork],
                countryCode: String = "AU",
                currencyCode: String = "AUD") {
      self.merchantIdentifier = merchantIdentifier
      self.allowedCardNetworks = allowedCardNetworks
      self.countryCode = countryCode
      self.currencyCode = currencyCode
    }
  }
}

#endif
