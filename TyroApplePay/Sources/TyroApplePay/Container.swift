//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 11/2/2024.
//

#if !os(macOS)

import Foundation
import Factory

extension Container {
  var payApiBaseUrl: Factory<String> {
    self { TyroApplePay.Constants.payApiBaseUrl.rawValue }
  }

  var payApiApplePayBaseUrl: Factory<String> {
    self {
      #if DEBUG
      TyroApplePay.Constants.payApiApplePaySandboxInboundBaseUrl.rawValue
      #else
      TyroApplePay.Constants.payPaiApplePayLiveInboundBaseUrl.rawValue
      #endif
    }
  }

  var payRequestViewModel: Factory<PayRequestViewModel> {
    self { PayRequestViewModel(
              applePayRequestService: self.applePayRequestService(),
              payRequestService: self.payRequestService(),
              applePayViewControllerHandler: self.applePayViewControllerHandler(),
              payRequestPoller: self.payRequestPoller()
    ) }.singleton
  }

  var applePayRequestService: Factory<ApplePayRequestService> {
    self { ApplePayRequestService(baseUrl: self.payApiApplePayBaseUrl(), httpClient: self.httpClient()) }.singleton
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
