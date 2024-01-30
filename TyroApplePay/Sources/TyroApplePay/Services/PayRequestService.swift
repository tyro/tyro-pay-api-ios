//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 11/2/2024.
//

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
}
