//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 11/2/2024.
//

import Foundation
import PassKit

public struct ApplePayRequest: Codable {
  var token: ApplePayToken
  var paymentType: String = "APPLE_PAY"
}

extension ApplePayRequest {
  static func createApplePayRequest(from paymentData: Data) throws -> ApplePayRequest {
    let paymentString = String(bytes: paymentData, encoding: .utf8)
    assert(!((paymentString?.count ?? 0) == 0),
           "Using Apple Pay with an iOS Simulator will always return an empty security token.")

    let decoder = JSONDecoder()
    let applePayPaymentData = try decoder.decode(ApplePayPaymentData.self, from: paymentData)
    let applePayToken = ApplePayToken(paymentData: applePayPaymentData)
    return ApplePayRequest(token: applePayToken)
  }
}

public struct ApplePayToken: Codable {
  var paymentData: ApplePayPaymentData
}

public struct ApplePayPaymentData: Codable {
  var data: String
  var version: String
  var signature: String
  var header: ApplePayHeader
}

public struct ApplePayHeader: Codable {
  var publicKeyHash: String
  var ephemeralPublicKey: String
  var transactionId: String
}
