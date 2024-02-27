//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 23/2/2024.
//

#if os(iOS)

import Nimble
import Quick
import Combine
import Foundation
import Factory
@testable import TyroApplePay

final class PayRequestPollerSpec: QuickSpec {

  class override func spec() {

    describe("start") {
      it ("should return the required PayRequestReponse") {
        let payRequestServiceMock = PayRequestServiceMock(
          baseUrl: "localhost",
          httpClient: Container.shared.httpClient(),
          payRequestResponseJsonString: PayRequestPollerFixtures.payRequestSuccessResponse)
        let poller = PayRequestPoller(payRequestService: payRequestServiceMock)

        waitUntil { done in
          poller.start(with: "paySecret") { response in
            return true
          } completion: { response in
            expect(response).toNot(beNil())
            expect(response?.status).to(equal(PayRequestStatus.success))
            done()
          }
        }
      }

      context("when things go wrong") {

        it ("should return the required PayRequestReponse") {
          let payRequestServiceMock = PayRequestServiceMock(
            baseUrl: "localhost",
            httpClient: Container.shared.httpClient(),
            payRequestResponseJsonString: PayRequestPollerFixtures.payRequestSuccessResponse)
          let poller = PayRequestPoller(payRequestService: payRequestServiceMock)
          var counter = 0

          waitUntil(timeout: .seconds(20)) { done in
            poller.start(with: "paySecret") { response in
              counter += 1
              if counter < 3 {
                return false
              } else {
                return true
              }
            } completion: { response in
              expect(response).toNot(beNil())
              expect(response?.status).to(equal(PayRequestStatus.success))
              done()
            }
          }
        }

      }
    }
  }
}

#endif
