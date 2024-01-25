//
//  File.swift
//  
//
//  Created by Ronaldo Gomes on 23/1/2024.
//

import Foundation

public class Configuration {
  private struct MainBundle {
    static var prefix: String = {
      guard let prefix = Bundle.main.object(forInfoDictionaryKey: "AAPLOfferingApplePayBundlePrefix") as? String else {
        return ""
      }
      return prefix
    }()
  }
  
  public struct Merchant {
    static let identifier = "merchant.tyro-pay-api-sample-app"
  }
}
