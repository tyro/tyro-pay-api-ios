//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 18/3/2024.
//

#if os(iOS)

import PassKit

public enum PaymentItem {
	case custom(String, NSDecimalNumber)
	case discount(NSDecimalNumber)
	case tax(NSDecimalNumber)

	func createPKPaymentSummaryItem() -> PKPaymentSummaryItem {
		switch self {
		case .tax(let value):
			PKPaymentSummaryItem(label: "Tax", amount: value)
		case .discount(let value):
			PKPaymentSummaryItem(label: "Discount", amount: value)
		case .custom(let label, let value):
			PKPaymentSummaryItem(label: label, amount: value)
		}
	}
}

#endif
