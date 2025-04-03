//
//  PayRequestViewModel.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

import Foundation
import PassKit

#if os(iOS)

fileprivate extension Array where Element == PaymentItem {

  func createPKPaymentSummaryItems() -> [PKPaymentSummaryItem] {
    self.map { paymentItem in
      paymentItem.createPKPaymentSummaryItem()
    }
  }

}

public enum PayRequestState {
  case started, polling, cancelled, successed, failed(any Error)
}

class PayRequestViewModel: NSObject {
  private var state: PayRequestState!
  private var failed: Error?

  var config: TyroApplePay.Configuration!
	var layout: TyroApplePay.Layout!
  var paySecret: String!
	var vgsRoutePrefix: String!

	let formatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		return formatter
	}()

  private let validPayRequestStatuses: [PayRequestStatus] = [
    .awaitingPaymentInput,
    .awaitingAuthentication,
    .failed
  ]

  private let validPayRequestPollingStatuses: [PayRequestStatus] = [
    .success,
    .failed,
    .awaitingAuthentication
  ]

	private let payApiApplePayBaseUrlSuffix: String
  private let applePayRequestService: ApplePayRequestService
  private let payRequestService: PayRequestService
  private let applePayValidator: ApplePayValidator.Type
  private let applePayViewControllerHandler: ApplePayViewControllerHandler
  private let payRequestPoller: PayRequestPoller

  private var applePayContinuation: CheckedContinuation<TyroApplePay.Result, Error>?

	init(payApiApplePayBaseUrlSuffix: String,
				 applePayRequestService: ApplePayRequestService,
				 payRequestService: PayRequestService,
				 applePayViewControllerHandler: ApplePayViewControllerHandler,
				 payRequestPoller: PayRequestPoller,
				 applePayValidator: ApplePayValidator.Type = TyroApplePay.self) {
		self.payApiApplePayBaseUrlSuffix = payApiApplePayBaseUrlSuffix
    self.applePayRequestService = applePayRequestService
    self.payRequestService = payRequestService
    self.applePayViewControllerHandler = applePayViewControllerHandler
    self.payRequestPoller = payRequestPoller
    self.applePayValidator = applePayValidator
  }

  private func createPaymentRequest(_ paymentItems: [PaymentItem]) -> PKPaymentRequest {
    let paymentRequest = PKPaymentRequest()
    paymentRequest.supportedNetworks = config.allowedCardNetworks
    paymentRequest.paymentSummaryItems = paymentItems.createPKPaymentSummaryItems()
    paymentRequest.merchantIdentifier = config.merchantIdentifier
    paymentRequest.merchantCapabilities = [.threeDSecure]
    paymentRequest.countryCode = config.countryCode
    paymentRequest.currencyCode = config.currencyCode

    return paymentRequest
  }

  private func isApplePayReady() -> Bool {
    return self.applePayValidator.isApplePayAvailable()
  }

  public func startPayment(paySecret: String) async throws -> TyroApplePay.Result {
    self.state = .started
    self.paySecret = paySecret

    if !isApplePayReady() {
      throw TyroApplePayError.applePayNotReady
    }

		var payRequest: PayRequestResponse?
    do {
      payRequest = try await self.payRequestService.fetchPayRequest(with: paySecret)
		} catch {
			throw TyroApplePayError.unableToFetchPayRequest
		}

		guard let payRequest = payRequest else {
			throw TyroApplePayError.payRequestNotFound
		}

		guard let vgsRoutePrefix = payRequest.vgsRoutePrefix else {
			throw TyroApplePayError.invalidVGSRoute
		}
		self.vgsRoutePrefix = vgsRoutePrefix

		if !self.validPayRequestStatuses.contains(payRequest.status) {
			throw TyroApplePayError.invalidPayRequestStatus
		}

		let amount = self.formatter.string(for: payRequest.total.amount / 100)

		let paymentRequest = self.createPaymentRequest([.custom(layout.totalLabel, NSDecimalNumber(string: amount))])

		return try await withCheckedThrowingContinuation { continuation in
			applePayContinuation = continuation
			self.applePayViewControllerHandler.presentController(delegate: self, paymentRequest: paymentRequest)
		}
  }

  private func handleApplePayResult(
    payment: PKPayment) async throws -> PayRequestResponse {

    let applePayRequest = try ApplePayRequest.createApplePayRequest(from: payment.token.paymentData)
		try await self.applePayRequestService.submitPayRequest(with: self.paySecret,
																													 payload: applePayRequest,
																													 to: "\(self.vgsRoutePrefix!)\(self.payApiApplePayBaseUrlSuffix)")
    return try await self.handleCompleteFlow()
  }

  private func handleCompleteFlow() async throws -> PayRequestResponse {
    let result = await self.payRequestPoller.start(with: self.paySecret) { payRequestResponse in
      return self.validPayRequestPollingStatuses.contains(payRequestResponse.status)
    }
    guard let payRequestResponse = result else {
      throw TyroApplePayError.unableToFetchPayRequest
    }

    switch payRequestResponse.status {
    case .success: return payRequestResponse
    case .failed: throw TyroApplePayError.payRequestFailed
    case .processing: throw TyroApplePayError.payRequestTimeout
    default:
      throw TyroApplePayError.unknown
    }
  }
}

extension PayRequestViewModel: PKPaymentAuthorizationControllerDelegate {

  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

    Task {
			do {
				_ = try await self.handleApplePayResult(payment: payment)
				self.state = .successed
				completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
			} catch {
				self.state = .failed(error)
				completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
			}
    }
  }

  public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      Task.detached { @MainActor in
        switch self.state {
        case .successed:
          self.applePayContinuation?.resume(returning: .success)
        case .failed(let error):
					self.applePayContinuation?.resume(throwing: TyroApplePayError.failedWith(error))
        default:
          self.applePayContinuation?.resume(returning: .cancelled)
        }
      }
    }
  }
}

#endif
