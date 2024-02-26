//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Nimble
import Quick
import XCTest
import Combine
import Foundation
import Factory
import PassKit
@testable import TyroApplePay

final class PayRequestViewModelSpec: QuickSpec  {

  class func setupViewModel(
    payRequestServiceMock: PayRequestServiceMock,
    applePayRequestServiceMock: ApplePayRequestServiceMock,
    applePayViewControllerHandler: ApplePayViewControllerHandlerStub,
    payRequestPoller: PayRequestPoller,
    paySecret: String,
    tyroApplePay: TyroApplePay
  ) -> PayRequestViewModel {
    let viewModel = PayRequestViewModel(
      applePayRequestService: applePayRequestServiceMock,
      payRequestService: payRequestServiceMock,
      applePayViewControllerHandler: applePayViewControllerHandler,
      payRequestPoller: payRequestPoller,
      applePayValidator: TyroApplePayMock.self)
    viewModel.paySecret = paySecret
    viewModel.config = tyroApplePay.config
    return viewModel
  }

  class func payRequestPoller(
    payRequestServiceMock: PayRequestService) -> PayRequestPoller {
    return PayRequestPoller(payRequestService: payRequestServiceMock)
  }

  override class func spec() {

    describe("startPayment") {

      context("when all goes well") {
        let payRequestServiceMock = PayRequestServiceMock(
          baseUrl: "localhost",
          httpClient: Container.shared.httpClient(),
          payRequestResponseJsonString: PayRequestServiceFixtures.awaitingPaymentInput)
        var viewModel: PayRequestViewModel!

        let paySecret = "paySecret"

        let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
          liveMode: false,
          merchantIdentifier: "merchant.test",
          allowedCardNetworks: [.visa, .masterCard]
        ))

        beforeEach {
          TyroApplePayMock[.isApplePayAvailable] = true
        }

        it("should invoke completion handler with successful Result") {
          viewModel = PayRequestViewModel(
            applePayRequestService: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            payRequestService: payRequestServiceMock,
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(jsonString: ApplePayRequestServiceFixtures.valid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: PayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              payRequestResponseJsonString: PayRequestServiceFixtures.success)),
            applePayValidator: TyroApplePayMock.self)
          viewModel.paySecret = paySecret
          viewModel.config = tyroApplePay.config

          waitUntil { done in

            try! viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in
              switch result {
              case .success:
                _ = succeed()
              default:
                fail("should not have come here.")
              }
              done()
            })

          }
        }

        it("should invoke completion handler with cancelled Result") {
          viewModel = PayRequestViewModel(
            applePayRequestService: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            payRequestService: payRequestServiceMock,
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(),
            payRequestPoller: payRequestPoller(payRequestServiceMock: PayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              payRequestResponseJsonString: PayRequestServiceFixtures.success)),
            applePayValidator: TyroApplePayMock.self)
          viewModel.paySecret = paySecret
          viewModel.config = tyroApplePay.config

          waitUntil { done in
            try! viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in
              switch result {
              case .cancelled:
                _ = succeed()
              default:
                fail("should not have come here.")
              }
              done()
            })
          }
        }
      }

      context("when something goes wrong") {

        let payRequestServiceMock = PayRequestServiceMock(
          baseUrl: "localhost",
          httpClient: Container.shared.httpClient(),
          payRequestResponseJsonString: PayRequestServiceFixtures.awaitingPaymentInput)
        var viewModel: PayRequestViewModel!

        let tyroApplePay = TyroApplePay(config: TyroApplePay.Configuration(
          liveMode: false,
          merchantIdentifier: "merchant.test",
          allowedCardNetworks: [.visa, .masterCard]
        ))
        let paySecret = "paySecret"

        beforeEach {
          TyroApplePayMock.reset()
          TyroApplePayMock[.isApplePayAvailable] = true

          viewModel = PayRequestViewModel(
            applePayRequestService: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            payRequestService: payRequestServiceMock,
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(jsonString: ApplePayRequestServiceFixtures.valid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: payRequestServiceMock),
            applePayValidator: TyroApplePayMock.self)
          viewModel.paySecret = paySecret
          viewModel.config = tyroApplePay.config
        }

        it("should throw an assertion if Apple Pay is not ready") {
          TyroApplePayMock[.isApplePayAvailable] = false
          expect {
            try viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in })
          }.to(throwAssertion())
        }

        it("should throw an assertion when PayRequest status is neither AWAITING_PAYMENT_INPUT, AWAITING_AUTHENTICATION or FAILED") {
          let viewModel = setupViewModel(
            payRequestServiceMock: PayRequestServiceMock(
                                    baseUrl: "localhost",
                                    httpClient: Container.shared.httpClient(),
                                    payRequestResponseJsonString: PayRequestServiceFixtures.success),
            applePayRequestServiceMock: ApplePayRequestServiceMock(
                                    baseUrl: "localhost",
                                    httpClient: Container.shared.httpClient(),
                                    result: Result.success(())),
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(
              jsonString: ApplePayRequestServiceFixtures.valid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: payRequestServiceMock),
            paySecret: "paySecret",
            tyroApplePay: tyroApplePay)

          expect {
            try viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in })
          }.to(throwAssertion())
        }

        it("should throw TyroApplePayError.failedWith(NetworkError) if unable to fetch Pay Request") {
          let viewModel = setupViewModel(
            payRequestServiceMock: PayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient()),
            applePayRequestServiceMock: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(
              jsonString: ApplePayRequestServiceFixtures.valid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: payRequestServiceMock),
            paySecret: "paySecret",
            tyroApplePay: tyroApplePay)

          waitUntil { done in
            try! viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in
              switch result {
              case .error(let error):
                expect(error).to(matchError(TyroApplePayError.failedWith(NetworkError.unknown)))
              default:
                fail("should not have come here.")
              }
              done()
            })
          }
        }

        it("should invoke the completion closure with an error ") {
          let viewModel = setupViewModel(
            payRequestServiceMock: PayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              payRequestResponseJsonString: PayRequestServiceFixtures.awaitingPaymentInput),
            applePayRequestServiceMock: ApplePayRequestServiceMock(
              baseUrl: "localhost",
              httpClient: Container.shared.httpClient(),
              result: Result.success(())),
            applePayViewControllerHandler: ApplePayViewControllerHandlerStub(
              jsonString: ApplePayRequestServiceFixtures.invalid),
            payRequestPoller: payRequestPoller(payRequestServiceMock: payRequestServiceMock),
            paySecret: "paySecret",
            tyroApplePay: tyroApplePay)

          waitUntil { done in
            try! viewModel.startPayment(paySecret: "paySecret", paymentItems: [], completion: { (result: TyroApplePay.Result) in
              switch result {
              case .error(let error):
                expect(error).to(matchError(TyroApplePayError.failedWith(NetworkError.decode)))
              default:
                fail("should not have come here.")
              }
              done()
            })
          }
        }

      }
    }
  }
}

#endif
