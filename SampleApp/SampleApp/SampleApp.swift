//
//  SampleApp.swift
//  SampleApp
//
//  Created by Ronaldo Gomes on 25/1/2024.
//

import SwiftUI

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
					if #available(iOS 16, *) {
						ContentViewIOS16AndAbove()
					} else {
						ContentViewBeforeIOS16()
					}
        }
    }
}
