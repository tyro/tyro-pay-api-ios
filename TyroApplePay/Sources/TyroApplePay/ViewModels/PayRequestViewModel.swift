//
//  PayRequestViewModel.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

import Foundation
import PassKit

#if os(iOS)

extension Array where Element == PaymentItem {

  func createPKPaymentSummaryItems() -> [PKPaymentSummaryItem] {
    self.map { paymentItem in
      paymentItem.createPKPaymentSummaryItem()
    }
  }

}

enum PayRequestViewModelState {
  case started, polling, cancelled, successed, failed(Error)
}

class PayRequestViewModel: NSObject {
  private var modelState: PayRequestViewModelState!
  private var failed: Error?

  var config: TyroApplePay.Configuration!
  var paySecret: String!

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

  private let applePayRequestService: ApplePayRequestService
  private let payRequestService: PayRequestService
  private let applePayValidator: ApplePayValidator.Type
  private let applePayViewControllerHandler: ApplePayViewControllerHandler
  private let payRequestPoller: PayRequestPoller

  private var applePayContinuation: CheckedContinuation<TyroApplePay.Result, Error>?

  init(applePayRequestService: ApplePayRequestService,
       payRequestService: PayRequestService,
       applePayViewControllerHandler: ApplePayViewControllerHandler,
       payRequestPoller: PayRequestPoller,
       applePayValidator: ApplePayValidator.Type = TyroApplePay.self) {
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

  public func startPayment(paySecret: String, paymentItems: [PaymentItem]) async -> TyroApplePay.Result {
    self.modelState = .started
    self.paySecret = paySecret

    Logger.shared.info("startPayment()")
    if !isApplePayReady() {
      return .error(.applePayNotReady)
    }

    do {
      let payRequest = try await self.payRequestService.fetchPayRequest(with: paySecret)
      guard let payRequest = payRequest else {
        return .error(.payRequestNotFound)
      }
      if !self.validPayRequestStatuses.contains(payRequest.status) {
        return .error(
          TyroApplePayError.invalidPayRequestStatus(
            "Pay Request cannot be submitted when status is \(payRequest.status)"
          )
        )
      }

      let paymentRequest = self.createPaymentRequest(paymentItems)

      return try await withCheckedThrowingContinuation { continuation in
        applePayContinuation = continuation
        self.applePayViewControllerHandler.presentController(delegate: self, paymentRequest: paymentRequest)
      }

    } catch {
      return .error(.failedWith(error))
    }
  }

  func handleApplePayResult(
    payment: PKPayment) async throws -> PayRequestResponse {

    let applePayRequest = try ApplePayRequest.createApplePayRequest(from: payment.token.paymentData)
    try await self.applePayRequestService.submitPayRequest(with: self.paySecret, payload: applePayRequest)
    return try await self.handleCompleteFlow()
  }

  func handleCompleteFlow() async throws -> PayRequestResponse {
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
        self.modelState = .successed
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
      } catch {
        self.modelState = .failed(error)
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
      }
    }
  }

  public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      DispatchQueue.main.async {
        switch self.modelState {
        case .successed:
          self.applePayContinuation?.resume(returning: .success)
        case .failed(let error):
          self.applePayContinuation?.resume(returning: .error(TyroApplePayError.failedWith(error)))
        default:
          self.applePayContinuation?.resume(returning: .cancelled)
        }
      }
    }
  }
}

#endif
