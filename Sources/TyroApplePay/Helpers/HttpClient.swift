//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 31/1/2024.
//

#if os(iOS)

import Foundation
import Combine

public enum RequestMethod: String {
  case delete = "DELETE"
  case get = "GET"
  case patch = "PATCH"
  case post = "POST"
  case put = "PUT"
}

public enum NetworkError: LocalizedError {
	case invalidURL
	case unexpectedStatusCode
	case decode
	case unknown
	case system(String)

	public var errorDescription: String? {
		switch self {
		case .invalidURL: return "Invalid URL"
		case .unexpectedStatusCode: return "Unexpected status code"
		case .decode: return "Unable to decode payload"
		case .unknown: return "Unknown error"
		case .system(let message): return message
		}
	}
}

public struct EndPoint {
  var host: String
  var scheme: String = "https"
  var path: String
  var method: RequestMethod
  var headers: [String: String]?
  var body: Encodable?
  var queryParams: [String: String]?
  var pathParams: [String: String]?
}

public extension EndPoint {
  func createRequest() -> URLRequest? {
    var urlComponents = URLComponents()
    urlComponents.scheme = self.scheme
    urlComponents.host = self.host
    urlComponents.path = self.path
    urlComponents.queryItems = self.queryParams?.map { (key, value) in
      URLQueryItem(name: key, value: value)
    }
    urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    guard let url = urlComponents.url else {
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = self.method.rawValue
    request.allHTTPHeaderFields = self.headers
    if let body = self.body {
      let encoder = JSONEncoder()
      request.httpBody = try? encoder.encode(body)
    }
    return request
  }
}

class Networkable {

  internal let session: URLSession

  public init(session: URLSession = .shared) {
    self.session = session
  }

  func sendRequest<T: Decodable>(to endpoint: EndPoint) async throws -> T {
    fatalError("This method must be overriden")
  }
  func sendRequest(to endpoint: EndPoint, resultHandler: @escaping (Result<Void, NetworkError>) -> Void) {
    fatalError("This method must be overriden")
  }
  func sendRequest<T: Decodable>(to endpoint: EndPoint, resultHandler: @escaping (Result<T, NetworkError>) -> Void) {
    fatalError("This method must be overriden")
  }
  func sendRequest<T: Decodable>(to endpoint: EndPoint, type: T.Type) throws -> AnyPublisher<T, NetworkError> {
    fatalError("This method must be overriden")
  }
}

final class HttpClient: Networkable {
    override func sendRequest(to endpoint: EndPoint,
                              resultHandler: @escaping (Result<Void, NetworkError>) -> Void) {

    guard let urlRequest = endpoint.createRequest() else {
      resultHandler(.failure(.invalidURL))
      return
    }
    let urlTask = self.session.dataTask(with: urlRequest) { _, response, error in
      guard error == nil else {
        resultHandler(.failure(.system(error!.localizedDescription)))
        return
      }
      guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
        resultHandler(.failure(.unexpectedStatusCode))
        return
      }
      resultHandler(.success(Void()))
    }
    urlTask.resume()
  }

  override func sendRequest<T: Decodable>(to
                                          endpoint: EndPoint,
                                          resultHandler: @escaping (Result<T, NetworkError>) -> Void) {

    guard let urlRequest = endpoint.createRequest() else {
      resultHandler(.failure(.invalidURL))
      return
    }
    let urlTask = self.session.dataTask(with: urlRequest) { data, response, error in
      guard error == nil else {
        resultHandler(.failure(.system(error!.localizedDescription)))
        return
      }
      guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
        resultHandler(.failure(.unexpectedStatusCode))
        return
      }
      guard let data = data, let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
        resultHandler(.failure(.decode))
        return
      }
      resultHandler(.success(decodedResponse))
    }
    urlTask.resume()
  }

  override func sendRequest<T>(to endpoint: EndPoint,
                               type: T.Type) throws -> AnyPublisher<T, NetworkError> where T: Decodable {
    guard let urlRequest = endpoint.createRequest() else {
			throw NetworkError.invalidURL
    }
    return self.session.dataTaskPublisher(for: urlRequest)
      .subscribe(on: DispatchQueue.global(qos: .background))
      .tryMap { data, response -> Data in
        guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
          throw NetworkError.unexpectedStatusCode
        }
        return data
      }
      .decode(type: T.self, decoder: JSONDecoder())
      .mapError { error -> NetworkError in
        if error is DecodingError {
          return NetworkError.decode
        } else if let error = error as? NetworkError {
          return error
        } else {
          return NetworkError.system(error.localizedDescription)
        }
      }
      .eraseToAnyPublisher()
  }

  override func sendRequest<T: Decodable>(to endpoint: EndPoint) async throws -> T {
    guard let urlRequest = endpoint.createRequest() else {
      throw NetworkError.invalidURL
    }
    return try await withCheckedThrowingContinuation { continuation in
      let task = self.session.dataTask(with: urlRequest) { data, response, _ in
          guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            continuation.resume(throwing:
                                  NetworkError.unexpectedStatusCode)
            return
          }
          guard let data = data, let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
            continuation.resume(throwing: NetworkError.decode)
            return
          }
          continuation.resume(returning: decodedResponse)
        }
      task.resume()
    }
  }
}

#endif
