//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 11/2/2024.
//

#if os(iOS)

import Foundation
import Factory

extension Container {
  var payApiBaseUrl: Factory<String> {
    self { TyroApplePay.Constants.payApiBaseUrl.rawValue }
  }

  var payApiApplePayBaseUrlSuffix: Factory<String> {
    self {
      #if DEBUG
      TyroApplePay.Constants.payApiApplePaySandboxInboundBaseUrl.rawValue
      #else
      TyroApplePay.Constants.payApiApplePayLiveInboundBaseUrl.rawValue
      #endif
    }
  }

  var payRequestViewModel: Factory<PayRequestViewModel> {
    self { PayRequestViewModel(
							payApiApplePayBaseUrlSuffix: self.payApiApplePayBaseUrlSuffix(),
              applePayRequestService: self.applePayRequestService(),
              payRequestService: self.payRequestService(),
              applePayViewControllerHandler: self.applePayViewControllerHandler(),
              payRequestPoller: self.payRequestPoller()
    ) }.singleton
  }

  var applePayRequestService: Factory<ApplePayRequestService> {
    self { ApplePayRequestService(httpClient: self.httpClient()) }.singleton
  }

  var payRequestService: Factory<PayRequestService> {
    self { PayRequestService(baseUrl: self.payApiBaseUrl(), httpClient: self.httpClient()) }.singleton
  }

  var httpClient: Factory<HttpClient> {
    self { HttpClient() }.singleton
  }

  var applePayViewControllerHandler: Factory<ApplePayViewControllerHandler> {
    self { ApplePayViewControllerHandler() }.singleton
  }

  var payRequestPoller: Factory<PayRequestPoller> {
    self { PayRequestPoller(payRequestService: self.payRequestService()) }.singleton
  }
}

#endif
