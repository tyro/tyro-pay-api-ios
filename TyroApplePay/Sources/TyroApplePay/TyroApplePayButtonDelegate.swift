//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 10/2/2024.
//

#if os(iOS)

import Foundation

public protocol TyroApplePayButtonDelegate {
  func onPaymentResult(result: TyroApplePay.Result)
}

#endif
