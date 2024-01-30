//
//  PayRequestError.swift
//
//
//  Created by Ronaldo Gomes on 7/2/2024.
//

import Foundation

enum PayRequestErrorType: String, Decodable {
  case clientValidationError = "CLIENT_VALIDATION_ERROR"
  case serverValidationError = "SERVER_VALIDATION_ERROR"
  case cardError = "CARD_ERROR"
  case serverError = "SERVER_ERROR"
  case unknownError = "UNKNOWN_ERROR"
}

struct PayRequestError: Error {
  let errorMessage: String = "Something went wrong"
  let errorType: PayRequestErrorType = PayRequestErrorType.unknownError
  let errorCode: String? = nil
  let gatewayCode: String? = nil
}
