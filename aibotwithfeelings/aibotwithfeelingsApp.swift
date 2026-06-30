//
//  aibotwithfeelingsApp.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

@main
struct aibotwithfeelingsApp: App {
    @State private var appModel: AppModel

    init() {
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_RESET") {
            let store = LocalMemoryStore()
            store.saveProfile(.guest)
            store.clearChatHistory()
            store.saveMemories([])
        }
        _appModel = State(initialValue: AppModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appModel: appModel)
        }
    }
}
