//
//  ApplePayPayRequest.swift
//
//
//  Created by Ronaldo Gomes on 7/2/2024.
//

import Foundation

class ApplePayRequestService {
  private let baseUrl: String
  private let httpClient: HttpClient

  init(baseUrl: String, httpClient: HttpClient) {
    self.baseUrl = baseUrl
    self.httpClient = httpClient
  }

  func submitPayRequest(with paySecret: String,
                        payload: ApplePayRequest,
                        handler completion: @escaping (Result<Void, NetworkError>) -> Void) {

    let endpoint = EndPoint(host: self.baseUrl,
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
}