//
//  PayRequestResponse.swift
//
//
//  Created by Ronaldo Gomes on 7/2/2024.
//

import Foundation

struct PayRequestOrigin: Decodable {
  let orderId: String
  let orderReference: String?
  let name: String
}

struct AmountWithCurrency: Decodable {
  let amount: Decimal
  let currency: String
}

struct Capture: Decodable {
  let method: CaptureMethod
  let total: AmountWithCurrency?
}

enum PayRequestStatus: String, Codable {
  case awaitingPaymentInput = "AWAITING_PAYMENT_INPUT"
  case awaitingAuthentication = "AWAITING_AUTHENTICATION"
  case processing = "PROCESSING"
  case success = "SUCCESS"
  case failed = "FAILED"
  case voided = "VOIDED"
}

enum CaptureMethod: String, Codable {
  case automatic = "AUTOMATIC"
  case manual = "MANUAL"
}

struct PayRequestResponse: Decodable {
  let origin: PayRequestOrigin
  let status: PayRequestStatus
  let capture: Capture?
  let total: AmountWithCurrency
  let errorCode: String?
  let errorMessage: String?
  let gatewayCode: String?
	let vgsRoutePrefix: String?
}
