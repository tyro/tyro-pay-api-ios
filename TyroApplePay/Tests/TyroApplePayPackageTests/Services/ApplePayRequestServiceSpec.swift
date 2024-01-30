//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 15/2/2024.
//

#if !os(macOS)

import Nimble
import Quick
import XCTest
import Combine
import Foundation
@testable import TyroApplePay

final class ApplePayRequestServiceSpec: QuickSpec  {

  override class func spec() {

    describe("submitPayRequest") {
      let paySecret = "paySecret"
      let applePayJsonString = """
        {
        "data": "P3h10lZHjXCooO5WoLf/d9VL0/xT3GKfN5Qy296Ljiq1HYR6kZXGCY8UbGxcfCsKpBoS5gJtPESn+qZ66pBeMThLJXR8t5Bim0oSlbIB0s27U1W80jtviQpzDvMkNBDvZ6+hCaMQYp5lVRoq2ngRGOy/KqwY+2mtaztG60NKSU8rZkSLy9g7QEpSdgrS/9XesWnLQDq3A02Yr6H0AiMnKuDjwa4lw1Vjir7zaewtX2Q1qjAMHglnLebqvM7RiuxoNvzn34tViKwdFNmttXkgu121woKKSvB1JgTDfoSqo0XAxEPmWb/CT+/klEh1ad5drijmwuF1+sCJKwQ86mQNbLNVoMlDst0osjzW3lNNJieZ4LebPRfpUeX1MmmXzXo2EgI3UEXLBLDkH1T50lWrJbqORR9sdO4p4hTPrrlZnJMutZXsc8dy0p0xzsEiUNp+bSoxerC8/7c1XVKH8kL0dXHjVpOJh7m0B2X2tEvhORgm1l2Gjep6RuoL52XGmel3TZudl1BzzNOm2qNoVxAP4tqfnITLIxRDm3pGln3yz7DuUiKi7cLY/Frz",
        "signature": "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",
        "header": {
        "publicKeyHash": "mngKGtPT2FQh0frY2NiEBjUzjTIfVxOiJwNtNPmMFA8=",
        "ephemeralPublicKey": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAET7rP4nz8tBjCSiioMiMBbDedty1yJ3CcXCDwU0bHdFX3nNZAWYo/CJvt9nViqHGB2/uLLM3rPkxDt/7PLH6b5w==",
        "transactionId": "20f57bc037ce09c7c9a396ae62e1c8b6198eda7c6e8b1cc2300ba6b909a51aac"
        },
        "version": "EC_v1"
        }
        """
      let applePayPaymentData = applePayJsonString.data(using: .utf8)!
      let applePayRequestData = try! ApplePayRequest.createApplePayRequest(from: applePayPaymentData)

      let endpoint = EndPoint(host: "localhost",
                              path: "/connect/pay/client/requests",
                              method: .patch,
                              headers: ["Pay-Secret": paySecret],
                              body: applePayRequestData)

      it("should return a successful result") {
        let mockedSession = createURLSessionMock(endPoint: endpoint)
        let mockedHttpClient = HttpClient(session: mockedSession)
        let service = ApplePayRequestService(baseUrl: "localhost", httpClient: mockedHttpClient)
        let expectedUrlRequest = endpoint.createRequest()

        waitUntil { done in
          service.submitPayRequest(with: paySecret, payload: applePayRequestData) { result in
            expect(URLProtocolMock.mockedURLRequest[expectedUrlRequest?.url]).to(equal(expectedUrlRequest))
            expect(result).to(beSuccess())
            done()
          }
        }
      }

      it("should return a failed result") {

        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, statusCode: 400))
        let applePayRequestData = try ApplePayRequest.createApplePayRequest(from: applePayPaymentData)
        let service = ApplePayRequestService(baseUrl: "localhost", httpClient: httpClient)
        let expectedUrlRequest = endpoint.createRequest()

        waitUntil { done in
          service.submitPayRequest(with: paySecret, payload: applePayRequestData) { result in
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
