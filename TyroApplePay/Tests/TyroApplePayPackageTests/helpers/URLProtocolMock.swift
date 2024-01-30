//
//  URLProtocolMock.swift
//
//
//  Created by Ronaldo Gomes on 5/2/2024.
//

#if !os(macOS)

import Foundation
@testable import TyroApplePay

class URLProtocolMock: URLProtocol {

  typealias MockedRequest = (error: Error?, data: Data?, response: HTTPURLResponse?)

  static var mockURLs = [URL?: MockedRequest]()
  static var mockedURLRequest = [URL?: URLRequest?]()

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    if let url = request.url {
      if let (error, data, response) = URLProtocolMock.mockURLs[url] {

        if let responseStrong = response {
          self.client?.urlProtocol(self, didReceive: responseStrong, cacheStoragePolicy: .notAllowed)
        }

        if let dataStrong = data {
          self.client?.urlProtocol(self, didLoad: dataStrong)
        }

        if let errorStrong = error {
          self.client?.urlProtocol(self, didFailWithError: errorStrong)
        }
      }
    }

    self.client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

func createURLSessionMock(endPoint: EndPoint, statusCode: Int = 200, jsonString: String? = nil, error: NetworkError? = nil) -> URLSession {
  let request = endPoint.createRequest()
  let url = request?.url!

  var data: Data = Data()
  if let jsonString = jsonString, let unwrappedData = jsonString.data(using: .utf8) {
    data = unwrappedData
  }
  var response: HTTPURLResponse?
  if let url = request?.url {
    response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: endPoint.headers)
  }
  URLProtocolMock.mockURLs = [url: (error, data, response)]
  URLProtocolMock.mockedURLRequest = [url: request]

  let sessionConfiguration = URLSessionConfiguration.ephemeral
  sessionConfiguration.protocolClasses = [URLProtocolMock.self]
  return URLSession(configuration: sessionConfiguration)
}

#endif
