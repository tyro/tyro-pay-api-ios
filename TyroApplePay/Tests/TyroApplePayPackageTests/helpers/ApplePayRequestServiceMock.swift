//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 21/2/2024.
//

#if !os(macOS)

import Foundation
import PassKit
@testable import TyroApplePay

class ApplePayRequestServiceMock: ApplePayRequestService {

  var result: Result<Void, NetworkError>

  init(baseUrl: String, httpClient: HttpClient, result: Result<Void, NetworkError>) {
    self.result = result
    super.init(baseUrl: baseUrl, httpClient: httpClient)
  }

  override func submitPayRequest(with paySecret: String,
                                 payload: ApplePayRequest,
                                 handler completion: @escaping (Result<Void, NetworkError>) -> Void) {

    completion(self.result)
  }
}

#endif
