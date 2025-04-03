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

final class PayRequestPollerSpec: AsyncSpec {

  class override func spec() {

    describe("start") {
      context("when it all works") {
				it("should return the required PayRequestReponse") {
          let payRequestServiceMock = PayRequestServiceMock(
            baseUrl: "localhost",
            httpClient: Container.shared.httpClient(),
            payRequestResponseJsonString: PayRequestPollerFixtures.payRequestSuccessResponse)
          let poller = PayRequestPoller(payRequestService: payRequestServiceMock, pollingInterval: 1_000_000_000, maxRetries: 3)
          var counter = 0

          let result = await poller.start(with: "paySecret") { response in
            counter += 1
            return counter < 3 ? false : true
          }
          expect(result).toNot(beNil())
          expect(result?.status).to(equal(PayRequestStatus.success))
        }
      }

      context("when things go wrong") {
        it("should return nil if unable to find a pay request") {
          let payRequestServiceMock = PayRequestServiceMock(
            baseUrl: "localhost",
            httpClient: Container.shared.httpClient(),
            payRequestResponseJsonString: PayRequestPollerFixtures.badPayRequestResponse)
          let poller = PayRequestPoller(payRequestService: payRequestServiceMock, pollingInterval: 1_000_000_000, maxRetries: 3)
          var counter = 0

          let result = await poller.start(with: "paySecret") { response in
            counter += 1
            return false
          }
          expect(result).to(beNil())
        }
      }
    }
  }
}

#endif
