//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 10/2/2024.
//

#if !os(macOS)

import Foundation

public protocol TyroApplePayButtonDelegate {
  func onPaymentResult(result: TyroApplePay.Result)
}

#endif
