//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if os(iOS)

import Foundation
import PassKit
@testable import TyroApplePay

class PayRequestServiceMock: PayRequestService {

  let payRequestResponseJsonString: String?

  init(baseUrl: String, httpClient: HttpClient, payRequestResponseJsonString: String? = nil) {
    self.payRequestResponseJsonString = payRequestResponseJsonString
    super.init(baseUrl: baseUrl, httpClient: httpClient)
  }

  override func fetchPayRequest(with paySecret: String,
                                handler completion: @escaping (Result<PayRequestResponse?, NetworkError>) -> Void) {
    if let payRequestResponseJsonString = self.payRequestResponseJsonString {
      let payRequestResponse: PayRequestResponse = try! JSONDecoder().decode(PayRequestResponse.self, from: payRequestResponseJsonString.data(using: .utf8)!)
      completion(Result.success(payRequestResponse))
    } else {
      completion(.failure(NetworkError.unknown))
    }
  }
}

#endif
