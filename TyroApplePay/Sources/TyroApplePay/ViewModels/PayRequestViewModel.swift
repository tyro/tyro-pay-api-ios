//
//  File.swift
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
  case started, cancelled, successed, errored(Error)
}

typealias PaymentCompletionHandler = (_ result: TyroApplePay.Result) -> Void

class PayRequestViewModel: NSObject {
  private var modelState: PayRequestViewModelState!
  private var isCancelled: Bool = true
  private var failed: Error?

  var completionHandler: PaymentCompletionHandler!

  // TODO: find a better way to inject these values
  var config: TyroApplePay.Configuration!
  var paySecret: String!

  private let validPayRequestStatuses: [PayRequestStatus] = [
    .awaitingPaymentInput,
    .awaitingAuthentication,
    .failed
  ]

  private let applePayRequestService: ApplePayRequestService
  private let payRequestService: PayRequestService
  private let applePayValidator: ApplePayValidator.Type
  private let applePayViewControllerHandler: ApplePayViewControllerHandler

  init(applePayRequestService: ApplePayRequestService,
       payRequestService: PayRequestService,
       applePayViewControllerHandler: ApplePayViewControllerHandler,
       applePayValidator: ApplePayValidator.Type = TyroApplePay.self) {
    self.applePayRequestService = applePayRequestService
    self.payRequestService = payRequestService
    self.applePayViewControllerHandler = applePayViewControllerHandler
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
        assert((self?.validPayRequestStatuses.contains(payRequest.status) ?? false),
               "Pay Request cannot be submitted when status is \(payRequest.status)")

        let paymentRequest = self?.createPaymentRequest(paymentItems)

        self?.applePayViewControllerHandler.presentController(delegate: self!, paymentRequest: paymentRequest!)

      case .failure(let error):
        completion(.error(.failedWith(error)))
      }
    }
  }

  func handleApplePayResult(payment: PKPayment, completion: @escaping (Result<Void, NetworkError>) -> Void) throws {
    let applePayRequest = try ApplePayRequest.createApplePayRequest(from: payment.token.paymentData)
    self.applePayRequestService.submitPayRequest(with: self.paySecret!, payload: applePayRequest, handler: completion)
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
//          self.isCancelled.toggle()
          self.modelState = .successed
          completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: nil))
        case .failure(let error):
          self.modelState = .errored(error)
//          self.failed = error
          completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
        }
      }
    } catch {
      self.modelState = .errored(error)
//      self.failed = error
      completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
    }
  }

  public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
      DispatchQueue.main.async {
        switch self.modelState {
        case .successed:
          self.completionHandler(.success)
        case .errored(let error):
          self.completionHandler(.error(TyroApplePayError.failedWith(error)))
        default:
          self.completionHandler(.cancelled)
        }
      }
    }
  }
}

#endif
