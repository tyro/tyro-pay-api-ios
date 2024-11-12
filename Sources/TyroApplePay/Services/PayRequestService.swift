//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 11/2/2024.
//

#if os(iOS)

import Foundation

class PayRequestService {
  private let baseUrl: String
  private let httpClient: HttpClient

  init(baseUrl: String, httpClient: HttpClient) {
    self.baseUrl = baseUrl
    self.httpClient = httpClient
  }

  func fetchPayRequest(with paySecret: String,
                       handler completion: @escaping (Result<PayRequestResponse, NetworkError>) -> Void) {
    let endpoint = EndPoint(host: self.baseUrl,
                            path: "/connect/pay/client/requests",
                            method: .get,
                            headers: ["Pay-Secret": paySecret])

    self.httpClient.sendRequest<PayRequestResponse>(to: endpoint, resultHandler: completion)
  }

  func fetchPayRequest(with paySecret: String) async throws -> PayRequestResponse {
    return try await withCheckedThrowingContinuation { continuation in
      self.fetchPayRequest(with: paySecret) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

#endif
