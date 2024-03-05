//
//  File.swift
//
//
//  Created by Ronaldo Gomes on 31/1/2024.
//

import Foundation
import SwiftyBeaver

public class Logger {
  static let shared = {
    let log = SwiftyBeaver.self
    let console = ConsoleDestination()
    console.useTerminalColors = true
    log.addDestination(console)
    log.debug("Initializing Logger")
    return log
  }()

  private init() {}
}
