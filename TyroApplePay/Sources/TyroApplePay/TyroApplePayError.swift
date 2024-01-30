//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 12/2/2024.
//

import Foundation

public enum TyroApplePayError: Error {
  case invalid
  case unableToProcessPayment(String?)
  case failedWith(Error)
}
