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

class ApplePayRequestServiceMock: ApplePayRequestService {

  var result: Result<Void, NetworkError>
	var paySecret: String!
	var payload: ApplePayRequest!
	var baseUrl: String!

  init(httpClient: HttpClient, result: Result<Void, NetworkError>) {
    self.result = result
    super.init(httpClient: httpClient)
  }

  override func submitPayRequest(with paySecret: String,
                                 payload: ApplePayRequest,
																 to baseUrl: String,
                                 handler completion: @escaping (Result<Void, NetworkError>) -> Void) {
		self.paySecret = paySecret
		self.payload = payload
		self.baseUrl = baseUrl
    completion(self.result)
  }
}

#endif
