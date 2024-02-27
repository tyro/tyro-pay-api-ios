//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 12/2/2024.
//

#if os(iOS)

import Foundation

public enum TyroApplePayError: Error {
  case invalid
  case invalidPaySecret
  case unableToProcessPayment(String?)
  case failedWith(Error)
  case applePayNotReady
  case payRequestNotFound
  case invalidPayRequestStatus(String)
}

#endif
