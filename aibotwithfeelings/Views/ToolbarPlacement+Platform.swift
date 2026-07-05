//
//  ToolbarPlacement+Platform.swift
//  aibotwithfeelings
//

import SwiftUI

extension ToolbarItemPlacement {
    static var platformLeading: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .cancellationAction
        #endif
    }

    static var platformTrailing: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .primaryAction
        #endif
    }
}
