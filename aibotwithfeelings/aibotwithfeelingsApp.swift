//
//  aibotwithfeelingsApp.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI
import SwiftData

@main
struct aibotwithfeelingsApp: App {

    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
        }
        .modelContainer(for: Message.self)
    }
}
