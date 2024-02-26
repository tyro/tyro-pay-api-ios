//
//  PayRequestViewModel.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

import Foundation
import PassKit

#if !os(macOS)

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

typealias PaymentCompletionHandler = (_ result: TyroApplePay.Result) -> Void

class PayRequestViewModel: NSObject {
  private var modelState: PayRequestViewModelState!
  private var failed: Error?

  var completionHandler: PaymentCompletionHandler!
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
    // TODO: move this to a configuration place
    paymentRequest.merchantIdentifier = config.merchantIdentifier
    // TODO: create a list of all options in a configuration place
    paymentRequest.merchantCapabilities = [.threeDSecure]
    paymentRequest.countryCode = config.countryCode
    paymentRequest.currencyCode = config.currencyCode

    return paymentRequest
  }

  private func isApplePayReady() -> Bool {
    return self.applePayValidator.isApplePayAvailable()
  }

  public func startPayment(paySecret: String,
                           paymentItems: [PaymentItem],
                           completion: @escaping PaymentCompletionHandler) throws {
    self.modelState = .started
    self.completionHandler = completion
    self.paySecret = paySecret

    Logger.shared.info("startPayment()")
    assert(isApplePayReady(), "Apple Pay is not available")

    self.payRequestService.fetchPayRequest(with: paySecret) { [weak self] result in
      switch result {
      case .success(let payRequest):
        guard let payRequest = payRequest else {
          preconditionFailure("Unable to find payRequest")
        }
        assert((self?.validPayRequestStatuses.contains(payRequest.status) ?? false),
               "Pay Request cannot be submitted when status is \(payRequest.status)")

        let paymentRequest = self?.createPaymentRequest(paymentItems)

        self?.applePayViewControllerHandler.presentController(delegate: self!, paymentRequest: paymentRequest!)

      case .failure(let error):
        completion(.error(.failedWith(error)))
      }
    }
  }

  func handleApplePayResult(
    payment: PKPayment,
    completion: @escaping (Result<PayRequestResponse, TyroApplePayError>) -> Void) throws {

    let applePayRequest = try ApplePayRequest.createApplePayRequest(from: payment.token.paymentData)
    self.applePayRequestService.submitPayRequest(with: self.paySecret!, payload: applePayRequest) { result in
      switch result {
      case .success(()):
        self.handleCompleteFlow(completion: completion)
      case .failure(let error):
        self.completionHandler(.error(.failedWith(error)))
      }
    }
  }

  func handleCompleteFlow(completion: @escaping (Result<PayRequestResponse, TyroApplePayError>) -> Void) {

    self.payRequestPoller.start(with: self.paySecret) { payRequestResponse in
      return self.validPayRequestPollingStatuses.contains(payRequestResponse.status)
    } completion: { payRequestResponse in

      guard let payRequestResponse = payRequestResponse else {
        completion(Result.failure(TyroApplePayError.invalidPaySecret))
        return
      }
      if payRequestResponse.status == .success {
        completion(Result.success(payRequestResponse))
      }

    }
  }
}

extension PayRequestViewModel: PKPaymentAuthorizationControllerDelegate {

  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    do {
      try self.handleApplePayResult(payment: payment) { result in
        switch result {
        case .success:
          self.modelState = .successed
          completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
        case .failure(let error):
          self.modelState = .failed(error)
          completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
        }
      }
    } catch {
      self.modelState = .failed(error)
      completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
    }
  }

  public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      DispatchQueue.main.async {
        switch self.modelState {
        case .successed:
          self.completionHandler(.success)
        case .failed(let error):
          self.completionHandler(.error(TyroApplePayError.failedWith(error)))
        default:
          self.completionHandler(.cancelled)
        }
      }
    }
  }
}

#endif
