//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 14/2/2024.
//

import Foundation

#if !os(macOS)
#if DEBUG
extension Data {
  func printJSON() {
    if let JSONString = String(data: self, encoding: String.Encoding.utf8) {
      print(JSONString)
    }
  }
}
#endif
#endif
