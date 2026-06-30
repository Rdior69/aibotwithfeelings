//
//  ContentView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        RootView(appModel: appModel)
    }
}

#Preview {
    ContentView(appModel: AppModel())
}
