//
//  Slider_DesignsApp.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

@main
struct Slider_DesignsApp: App {
    init() {
        // Tint the segmented picker. This is a global UIKit appearance, so set it once at launch.
        UISegmentedControl.appearance().backgroundColor = .brown.withAlphaComponent(0.15)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
