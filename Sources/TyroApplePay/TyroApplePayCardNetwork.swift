//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 10/4/2024.
//

import Foundation
import PassKit

public enum TyroApplePayCardNetwork {
	case amex
	case jcb
	case maestro
	case masterCard
	case visa
}

extension TyroApplePayCardNetwork: RawRepresentable, CaseIterable {
	public typealias RawValue = PKPaymentNetwork

	public static var allCases: [TyroApplePayCardNetwork] = [.amex, .jcb, .maestro, .masterCard, .visa]

	public init?(rawValue: RawValue) {
		guard let tyroNetwork = { () -> TyroApplePayCardNetwork? in
			TyroApplePayCardNetwork.allCases.first { $0.rawValue == rawValue }
		}() else { return nil }
		self = tyroNetwork
	}

	public var rawValue: RawValue {
		switch self {
		case .amex: return .amex
		case .jcb: return .JCB
		case .maestro: return .maestro
		case .masterCard: return .masterCard
		case .visa: return .visa
		}
	}
}
