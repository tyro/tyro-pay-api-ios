//
//  HttpClientSpec.swift
//
//
//  Created by Ronaldo Gomes on 3/2/2024.
//

#if os(iOS)

import Nimble
import Quick
import Combine
import Foundation
@testable import TyroApplePay

public struct City: Codable, Equatable {
  let name: String
}

final class CompletionHandlerHttpClientSpec: QuickSpec  {

  override class func spec() {

    let endpoint = EndPoint(
      host: "localhost",
      scheme: "https",
      path: "/v1",
      method: RequestMethod.get
    )

    describe("sendRequest") {

      it("should work") {
        let jsonString = """
          {
            "name": "Sydney"
          }
        """

        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, jsonString: jsonString))

        waitUntil { done in
          httpClient.sendRequest(to: endpoint) { (result: Result<City, NetworkError>) -> Void in
            expect(result).to(beSuccess { city in
              expect(city.name).to(equal("Sydney"))
              expect(URLProtocolMock.mockedURLRequest[endpoint.createRequest()!.url!]).to(equal(endpoint.createRequest()))
              done()
            })
          }
        }
      }

      it("should fail when it is unable to parse the data") {
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint))

        waitUntil { done in
          httpClient.sendRequest(to: endpoint) { (result: Result<City, NetworkError>) -> Void in
            expect(result).to(beFailure { error in
              expect(URLProtocolMock.mockedURLRequest[endpoint.createRequest()!.url!]).to(equal(endpoint.createRequest()))
              expect(error).to(matchError(NetworkError.decode))
              done()
            })
          }
        }
      }

      it("should fail when there is any system domain error") {
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, error: NetworkError.system("some error")))

        waitUntil { done in
          httpClient.sendRequest(to: endpoint) { (result: Result<City, NetworkError>) -> Void in
            expect(result).to(beFailure { error in
              expect(URLProtocolMock.mockedURLRequest[endpoint.createRequest()!.url!]).to(equal(endpoint.createRequest()))
              expect(error).to(matchError(NetworkError.system("error")))
              done()
            })
          }
        }
      }

      it("should fail with NetworkError.unexpectedStatusCode") {
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, statusCode: 400))

        waitUntil { done in
          httpClient.sendRequest(to: endpoint) { (result: Result<City, NetworkError>) -> Void in
            expect(result).to(beFailure { error in
              expect(URLProtocolMock.mockedURLRequest[endpoint.createRequest()!.url!]).to(equal(endpoint.createRequest()))
              expect(error).to(matchError(NetworkError.unexpectedStatusCode))
              done()
            })
          }
        }
      }

      it("should fail when endpoint generates an invalid URL") {
        let wrongEndpoint = EndPoint(
          host: "some invalid host",
          path: "//v1",
          method: RequestMethod.get
        )

        let httpClient = HttpClient(session: createURLSessionMock(endPoint: wrongEndpoint, statusCode: 400, error: NetworkError.invalidURL))

        waitUntil { done in
          httpClient.sendRequest(to: wrongEndpoint) { (result: Result<City, NetworkError>) -> Void in
            expect(result).to(beFailure { error in
              expect(URLProtocolMock.mockedURLRequest[wrongEndpoint.createRequest()?.url]).to(beNil())
              expect(error).to(matchError(NetworkError.invalidURL))
              done()
            })
          }
        }
      }
    }
  }
}

final class CombineHttpClientSpec: QuickSpec {

  override class func spec() {
    let endpoint = EndPoint(
      host: "localhost",
      scheme: "https",
      path: "/v1",
      method: RequestMethod.get
    )

    var cancellables: Set<AnyCancellable>!
    var error: Error?
    var city: City?

    beforeEach {
      cancellables = []
      city = nil
      error = nil
    }

    describe("sendRequest") {

      context("when it works") {

        it("should return the decoded response") {

          let jsonString = """
          {
            "name": "Sydney"
          }
          """

          let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, jsonString: jsonString))

          waitUntil { done in
            httpClient.sendRequest(to: endpoint, type: City.self)
              .sink { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let encounteredError):
                  error = encounteredError
                }
              } receiveValue: { foundCity in
                city = foundCity
                done()
              }
              .store(in: &cancellables)
          }

          expect(error).to(beNil())
          expect(city).to(equal(City(name: "Sydney")))
        }
      }

      context("when things going wrong") {

        it("should fail when unable to decode response") {
          let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint))

          waitUntil { done in
            httpClient.sendRequest(to: endpoint, type: City.self)
              .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let encounteredError):
                  error = encounteredError
                  done()
                }
              }, receiveValue: { foundCity in
                city = foundCity
                done()
              })
              .store(in: &cancellables)
          }

          expect(city).to(beNil())
          expect(error).to(matchError(NetworkError.decode))
        }

        it("should fail when unexpected status code") {
          let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, statusCode: 400))

          waitUntil { done in
            httpClient.sendRequest(to: endpoint, type: City.self)
              .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let encounteredError):
                  error = encounteredError
                  done()
                }
              }, receiveValue: { foundCity in
                city = foundCity
                done()
              })
              .store(in: &cancellables)
          }

          expect(city).to(beNil())
          expect(error).to(matchError(NetworkError.unexpectedStatusCode))
        }

        it("should fail when some any system error") {
          let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, error: NetworkError.system("some error")))

          waitUntil { done in
            httpClient.sendRequest(to: endpoint, type: City.self)
              .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let encounteredError):
                  error = encounteredError
                  done()
                }
              }, receiveValue: { foundCity in
                city = foundCity
                done()
              })
              .store(in: &cancellables)
          }

          expect(city).to(beNil())
          expect(error).to(matchError(NetworkError.system("some error")))
        }
      }
    }
  }
}

final class AsyncHttpClientSpec: AsyncSpec  {

  override class func spec() {

    let endpoint = EndPoint(
      host: "localhost",
      scheme: "https",
      path: "/v1",
      method: RequestMethod.get
    )

    describe("sendRequest") {

      it("should work") {
        let jsonString = """
          {
            "name": "Sydney"
          }
        """
        let expectedCity = City(name: "Sydney")

        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, jsonString: jsonString))

        let result: City = try await httpClient.sendRequest(to: endpoint)

        expect(result).to(equal(expectedCity))
      }

      it("should fail with invalid url") {

        let wrongEndpoint = EndPoint(
          host: "some invalid host",
          path: "//v1",
          method: RequestMethod.get
        )

        let httpClient = HttpClient(session: createURLSessionMock(endPoint: wrongEndpoint, error: NetworkError.invalidURL))
        await expect {
          let city: City = try await httpClient.sendRequest(to: wrongEndpoint)
        }.to(throwError(NetworkError.invalidURL))
      }

      it("should fail with unexpected status code") {
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint, statusCode: 400, error: NetworkError.unexpectedStatusCode))
        await expect {
          let city: City = try await httpClient.sendRequest(to: endpoint)
        }.to(throwError(NetworkError.unexpectedStatusCode))
      }

      it("should fail with decode error") {
        let httpClient = HttpClient(session: createURLSessionMock(endPoint: endpoint))
        await expect {
          let city: City = try await httpClient.sendRequest(to: endpoint)
        }.to(throwError(NetworkError.decode))
      }
    }
  }
}

#endif
