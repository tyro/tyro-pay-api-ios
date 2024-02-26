//
//  PayRequestPoller.swift
//
//
//  Created by Ronaldo Gomes on 22/2/2024.
//

import Foundation

fileprivate final class Counter: @unchecked Sendable {

  private(set) var counter: Int = 0;

  func reset() {
    DispatchQueue.timerMutatingLock.sync {
      self.counter = 0
    }
  }

  func increment() {
    DispatchQueue.timerMutatingLock.sync {
      self.counter += 1
    }
  }

}

fileprivate extension DispatchQueue {

  static let timerMutatingLock = DispatchQueue(label: "timer.lock.queue")

}

internal class PayRequestPoller {

  typealias PollerTimeInterval = UInt64

  private let payRequestService: PayRequestService

  init(payRequestService: PayRequestService) {
    self.payRequestService = payRequestService
  }

  func start(with paySecret: String,
            pollingInterval: PollerTimeInterval = 2_000_000_000, // 2_000_000_000 nanoseconds -> 2 seconds
            maxRetries: Int = 60,
            conditionFn: @escaping (PayRequestResponse) -> Bool,
            completion: @escaping (PayRequestResponse?) -> Void) {
    Task {
      do {
        let runCounter: Counter = Counter()
        var statusResult: PayRequestResponse? = nil
        while (!self.hasReachedMaxRetries(runCounter, maxRetries)) {
          statusResult = try await self.payRequestService.fetchPayRequest(with: paySecret)

          guard let statusResult = statusResult else {
            break
          }
          if !conditionFn(statusResult) {
            try await Task.sleep(nanoseconds: pollingInterval)
            runCounter.increment()
          } else {
            break
          }
        }
        completion(statusResult)
      } catch {
        completion(nil)
      }
    }
  }

  private func hasReachedMaxRetries(_ counter: Counter, _ limit: Int) -> Bool {
    return counter.counter == limit
  }

}
