//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 10/2/2024.
//

import Foundation

public extension TyroApplePay {

  enum Result {
    case cancelled
    case success
    case error(TyroApplePayError)
  }

}
