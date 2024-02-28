//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 15/2/2024.
//

#if os(iOS)

import Nimble
import Quick
import Combine
import Foundation
@testable import TyroApplePay

final class PayRequestServiceSpec: QuickSpec  {

  override class func spec() {

    describe("fetchPayRequest") {

      it("should return a successful result") {
        let paySecret = "paySecret"
        let jsonString = PayRequestServiceFixtures.awaitingPaymentInput
        let endpoint = EndPoint(host: "localhost",
                                path: "/connect/pay/client/requests",
                                method: .get,
                                headers: ["Pay-Secret": paySecret])
        let expectedUrlRequest = endpoint.createRequest()
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, jsonString: jsonString))
        let service = PayRequestService(baseUrl: "localhost", httpClient: httpClient)

        waitUntil { done in
          service.fetchPayRequest(with: paySecret) { result in
            expect(result).to(beSuccess { value in
              expect(URLProtocolMock.mockedURLRequest[expectedUrlRequest?.url]).to(equal(expectedUrlRequest))
              expect(value?.origin.name).to(equal("Demo Pay Request"))
            })
            done()
          }
        }
      }

      it("should return a failed result") {
        let paySecret = "paySecret"
        let jsonString = PayRequestServiceFixtures.invalid
        let endpoint = EndPoint(host: "localhost",
                                path: "/connect/pay/client/requests",
                                method: .get,
                                headers: ["Pay-Secret": paySecret])
        let expectedUrlRequest = endpoint.createRequest()
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, jsonString: jsonString))

        let service = PayRequestService(baseUrl: "localhost", httpClient: httpClient)

        waitUntil { done in
          service.fetchPayRequest(with: paySecret) { result in
            expect(URLProtocolMock.mockedURLRequest[expectedUrlRequest?.url]).to(equal(expectedUrlRequest))
            expect(result).to(beFailure())
            done()
          }
        }
      }
    }
  }
}

#endif
