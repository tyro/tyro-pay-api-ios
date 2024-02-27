//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 12/2/2024.
//

#if os(iOS)

import Foundation

public enum TyroApplePayError: Error {
  case applePayNotReady
  case failedWith(Error)
  case invalid
  case invalidPaySecret
  case invalidPayRequestStatus(String)
  case payRequestFailed
  case payRequestNotFound
  case payRequestTimeout
  case unableToProcessPayment(String?)
  case unableToFetchPayRequest
  case unknown
}

#endif
