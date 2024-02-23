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

  private let payRequestService: PayRequestService

  init(payRequestService: PayRequestService) {
    self.payRequestService = payRequestService
  }

  func poll(paySecret: String,
            pollingInterval: TimeInterval = 2_000_000_000,
            maxRetries: Int = 60,
            conditionFn: @escaping (PayRequestResponse) -> Bool,
            completion: @escaping (PayRequestResponse?) -> Void) {
    Task {
      do {
        let runCounter: Counter = Counter()
        var statusResult: PayRequestResponse? = nil
        while (runCounter.counter <= maxRetries) {
          statusResult = try await self.payRequestService.fetchPayRequest(with: paySecret)

          guard let statusResult = statusResult else {
            return
          }
          if !conditionFn(statusResult) {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            runCounter.increment()
          } else {
            break
          }
        }
        completion(statusResult)
      } catch {
        print("failed")
      }
    }
  }

  private func hasReachedMaxRetries(counter: Counter, limit: Int) -> Bool {
    return counter.counter == limit
  }

}
