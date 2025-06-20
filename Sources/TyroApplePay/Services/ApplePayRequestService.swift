//
//  ApplePayPayRequest.swift
//
//
//  Created by Ronaldo Gomes on 7/2/2024.
//

#if os(iOS)

import Foundation

class ApplePayRequestService {
  private let httpClient: HttpClient

  init(httpClient: HttpClient) {
    self.httpClient = httpClient
  }

  func submitPayRequest(with paySecret: String,
                        payload: ApplePayRequest,
                        to baseUrl: String,
                        handler completion: @escaping (Result<Void, NetworkError>) -> Void) {

    let endpoint = EndPoint(host: baseUrl,
                            path: "/connect/pay/client/requests",
                            method: .patch,
                            headers: [
                              "Pay-Secret": paySecret,
                              "Content-Type": "application/json",
                              "Accept": "application/json"
                            ],
                            body: payload
    )

    self.httpClient.sendRequest(to: endpoint, resultHandler: completion)
  }

  func submitPayRequest(with paySecret: String,
                        payload: ApplePayRequest,
                        to baseUrl: String) async throws {

    _ = try await withCheckedThrowingContinuation { continuation in
			self.submitPayRequest(with: paySecret, payload: payload, to: baseUrl) { result in
				continuation.resume(with: result)
      }
    }
  }
}

#endif
