//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if os(iOS)

import Nimble
import Quick
import Combine
import Foundation
import Factory
import PassKit
@testable import TyroApplePay

final class PayRequestViewModelSpec: AsyncSpec  {

  class func setupViewModel(
    payRequestServiceMock: PayRequestServiceMock,
    applePayRequestServiceMock: ApplePayRequestServiceMock,
    applePayViewControllerHandler: ApplePayViewControllerHandlerStub,
    payRequestPoller: PayRequestPoller,
    paySecret: String,
		tyroApplePayConfig: TyroApplePay.Configuration
  ) -> PayRequestViewModel {
    let viewModel = PayRequestViewModel(
      applePayRequestService: applePayRequestServiceMock,
      payRequestService: payRequestServiceMock,
      applePayViewControllerHandler: applePayViewControllerHandler,
      payRequestPoller: payRequestPoller,
      applePayValidator: TyroApplePayMock.self)
    viewModel.paySecret = paySecret
    viewModel.config = tyroApplePayConfig
    return viewModel
  }

  class func payRequestPoller(
    payRequestServiceMock: PayRequestService) -> PayRequestPoller {
    return PayRequestPoller(payRequestService: payRequestServiceMock, pollingInterval: 1_000_000_000, maxRetries: 1)
  }

  override class func spec() {

    let paySecret = "paySecret"

    let tyroApplePayConfig = TyroApplePay.Configuration(
      merchantIdentifier: "merchant.test",
      allowedCardNetworks: [.visa, .masterCard]
    )

    let awaitingPaymentInputPayRequestServiceMock = PayRequestServiceMock(
      baseUrl: "localhost",
      httpClient: Container.shared.httpClient(),
      payRequestResponseJsonString: PayRequestServiceFixtures.awaitingPaymentInput)

    let successPayRequestServiceMock = PayRequestServiceMock(
      baseUrl: "localhost",
      httpClient: Container.shared.httpClient(),
      payRequestResponseJsonString: PayRequestServiceFixtures.success)

    let invalidPayRequestServiceMock = PayRequestServiceMock(
      baseUrl: "localhost",
      httpClient: Container.shared.httpClient(),
      payRequestResponseJsonString: PayRequestServiceFixtures.invalid)

    let failedPayRequestServiceMock = PayRequestServiceMock(
      baseUrl: "localhost",
      httpClient: Container.shared.httpClient())

    let successApplePayRequestServiceMock = ApplePayRequestServiceMock(
      baseUrl: "localhost",
      httpClient: Container.shared.httpClient(),
      result: Result.success(()))

    let validApplePayViewControllerHandlerStub = ApplePayViewControllerHandlerStub(jsonString: ApplePayRequestServiceFixtures.valid)
    let invalidApplePayViewControllerHandlerStub = ApplePayViewControllerHandlerStub(jsonString: ApplePayRequestServiceFixtures.invalid)
    let unauthorizedApplePayViewControllerHandlerStub = ApplePayViewControllerHandlerStub()

    let successPayRequestPoller = payRequestPoller(
      payRequestServiceMock: PayRequestServiceMock(
        baseUrl: "localhost",
        httpClient: Container.shared.httpClient(),
        payRequestResponseJsonString: PayRequestServiceFixtures.success
      )
    )

    let awaitingPaymentInputPayRequestPoller = payRequestPoller(
      payRequestServiceMock: PayRequestServiceMock(
        baseUrl: "localhost",
        httpClient: Container.shared.httpClient(),
        payRequestResponseJsonString: PayRequestServiceFixtures.awaitingPaymentInput
      )
    )

    describe("startPayment") {

      beforeEach {
        TyroApplePayMock.reset()
        TyroApplePayMock[.isApplePayAvailable] = true
      }

      context("when all goes well") {
        it("should invoke completion handler with successful Result") {
          let viewModel = setupViewModel(
            payRequestServiceMock: awaitingPaymentInputPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: validApplePayViewControllerHandlerStub,
            payRequestPoller: successPayRequestPoller,
            paySecret: paySecret,
            tyroApplePayConfig: tyroApplePayConfig)

          await expect {
            let result = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
            guard case .success = result else {
              return .failed(reason: "it should have succeeded.")
            }
            return .succeeded
          }.to(succeed())
        }

        it("should invoke completion handler with cancelled Result") {
          let viewModel = setupViewModel(
            payRequestServiceMock: awaitingPaymentInputPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: unauthorizedApplePayViewControllerHandlerStub,
            payRequestPoller: successPayRequestPoller,
            paySecret: paySecret,
						tyroApplePayConfig: tyroApplePayConfig)

          await expect {
            let result = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
            guard case .cancelled = result else {
              return .failed(reason: "it should have been cancelled")
            }
            return .succeeded

          }.to(succeed())
        }
      }

      context("when things go wrong") {
        it("should throw if Apple Pay is not ready") {
          TyroApplePayMock[.isApplePayAvailable] = false
          let viewModel = setupViewModel(
            payRequestServiceMock: awaitingPaymentInputPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: validApplePayViewControllerHandlerStub,
            payRequestPoller: awaitingPaymentInputPayRequestPoller,
            paySecret: paySecret,
						tyroApplePayConfig: tyroApplePayConfig)


					do {
						_ = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
						fail()
					} catch let error as TyroApplePayError {
						expects((error as TyroApplePayError).description).to(equal(TyroApplePayError.applePayNotReady.description))
					}

        }

        it("should throw if pay request not found") {
          let viewModel = setupViewModel(
            payRequestServiceMock: invalidPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: validApplePayViewControllerHandlerStub,
            payRequestPoller: awaitingPaymentInputPayRequestPoller,
            paySecret: paySecret,
						tyroApplePayConfig: tyroApplePayConfig)

					do {
						_ = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
						fail()
					} catch let error as TyroApplePayError {
						expects(error.description).to(equal(TyroApplePayError.payRequestNotFound.description))
					}

        }

        it("should throw when PayRequest status is neither AWAITING_PAYMENT_INPUT, AWAITING_AUTHENTICATION or FAILED") {
          let viewModel = setupViewModel(
            payRequestServiceMock: successPayRequestServiceMock,
            applePayRequestServiceMock: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(
              jsonString: ApplePayRequestServiceFixtures.valid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: successPayRequestServiceMock),
            paySecret: "paySecret",
						tyroApplePayConfig: tyroApplePayConfig)

					do {
						_ = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
						fail()
					} catch let error as TyroApplePayError {
						expects(error.description).to(equal(TyroApplePayError.invalidPayRequestStatus.description))
					}
        }

        it("should throw NetworkError if unable to fetch Pay Request") {
          let viewModel = setupViewModel(
            payRequestServiceMock: failedPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: validApplePayViewControllerHandlerStub,
            payRequestPoller: payRequestPoller(payRequestServiceMock: failedPayRequestServiceMock),
            paySecret: "paySecret",
						tyroApplePayConfig: tyroApplePayConfig)


					do {
						_ = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
						fail()
					} catch let error as TyroApplePayError{
						expects(error.description).to(equal(TyroApplePayError.unableToProcessPayment.description))
					}
        }

        it("should throw when the value returned from Apple is invalid and unable to parse") {
          let viewModel = setupViewModel(
            payRequestServiceMock: awaitingPaymentInputPayRequestServiceMock,
            applePayRequestServiceMock: successApplePayRequestServiceMock,
            applePayViewControllerHandler: invalidApplePayViewControllerHandlerStub,
            payRequestPoller: payRequestPoller(payRequestServiceMock: awaitingPaymentInputPayRequestServiceMock),
            paySecret: "paySecret",
						tyroApplePayConfig: tyroApplePayConfig)

					do {
						_ = try await viewModel.startPayment(paySecret: "paySecret", paymentItems: [])
						fail()
					} catch let error as TyroApplePayError {
						expects(error.description).to(equal("The data couldn’t be read because it is missing."))
					}
        }
      }
    }
  }
}

#endif
