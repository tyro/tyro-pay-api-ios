//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 14/2/2024.
//

import Foundation

#if os(iOS)
#if DEBUG
extension Data {
  func printJSON() {
    if let JSONString = String(bytes: self, encoding: .utf8) {
      print(JSONString)
    }
  }
}
#endif
#endif
