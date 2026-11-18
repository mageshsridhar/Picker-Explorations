//
//  TempoViewModel.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

class TempoViewModel: ObservableObject {
    /// Tempo range shared by every dial, in beats per minute.
    static let minValue: Double = 60
    static let maxValue: Double = 200
    static let step: Double = 0.5

    /// Every selectable value: 60.0, 60.5, 61.0 … 200.0
    static let allValues: [Double] = Array(stride(from: minValue, through: maxValue, by: step))

    @Published var tempo: Double = minValue
}

/// Notched arrow pointing right, used as the dial indicator.
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let notchDepth = rect.width * 0.25
        var path = Path()
        path.move(to: CGPoint(x: rect.width, y: rect.midY))   // tip
        path.addLine(to: CGPoint(x: 0, y: 0))                  // top left
        path.addLine(to: CGPoint(x: notchDepth, y: rect.midY)) // notch
        path.addLine(to: CGPoint(x: 0, y: rect.height))        // bottom left
        path.closeSubpath()
        return path
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
