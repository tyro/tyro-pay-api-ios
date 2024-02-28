//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 12/2/2024.
//

#if os(iOS)

import Foundation

public enum TyroApplePayError: Error, CustomStringConvertible {
  case applePayNotReady
  case failedWith(Error)
  case invalid
  case invalidPaySecret
  case invalidPayRequestStatus
  case payRequestFailed
  case payRequestNotFound
  case payRequestTimeout
  case unableToProcessPayment
  case unableToFetchPayRequest
  case unknown

  public var description: String {
    switch self {
    case .applePayNotReady: return "Apple Pay not ready"
    case .failedWith(let errorMessage): return errorMessage.localizedDescription
    case .invalid: return "Invalid"
    case .invalidPaySecret: return "Invalid pay secret"
    case .invalidPayRequestStatus: return "Invalid pay request status"
    case .payRequestFailed: return "Pay request failed"
    case .payRequestNotFound: return "Pay request not found"
    case .payRequestTimeout: return "Pay request timeout"
    case .unableToProcessPayment: return "Unable to process payment"
    case .unableToFetchPayRequest: return "Unable to fetch pay request"
    case .unknown: return "Unknown error"
    }
  }
}

#endif
