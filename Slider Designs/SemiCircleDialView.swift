//
//  SemiCircleDialView.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

/// "Modern": a semi-circular dial. Drag vertically to change the value.
struct SemiCircleDialView: View {
    // MARK: - Configuration

    /// Higher values give slower, more precise dragging.
    private let scrollSensitivity: CGFloat = 5.0

    /// Angular distance between neighbouring values. Larger spaces the marks out more.
    private let anglePerUnit: Double = 12.5

    // MARK: - State

    @EnvironmentObject var tempoViewModel: TempoViewModel

    /// Value when the current drag began, so the drag offset is applied from a fixed origin.
    @State private var lastValueOnDragStart: Double = TempoViewModel.minValue

    private let impact = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let radius = side / 2.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            // Sized relative to the available space: 280 / 400 pt at the original 350 pt height,
            // with the outer ring capped to the width so it never spills off a phone screen.
            let innerDiameter = side * 0.8
            let outerDiameter = min(side * 8 / 7, geometry.size.width)

            ZStack {
                Circle()
                    .fill(.brown.gradient.tertiary)
                    .stroke(.brown, lineWidth: 1)
                    .frame(width: innerDiameter)
                Circle()
                    .fill(.brown.gradient.opacity(0.1))
                    .stroke(.brown.secondary, lineWidth: 1)
                    .frame(width: outerDiameter)
                Text("Tempo (bpm)")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.brown)
                    .offset(y: -40)
                Text(String(format: "%.1f", tempoViewModel.tempo))
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.primary)
                    .position(center)
                    .contentTransition(.numericText())
                    .animation(.spring(), value: tempoViewModel.tempo)

                // MARK: Dial markings
                ZStack {
                    ForEach(TempoViewModel.allValues, id: \.self) { value in
                        let angle = angle(for: value)

                        if isAngleVisible(angle) {
                            let isWholeNumber = value.truncatingRemainder(dividingBy: 1) == 0
                            // Circle and label share a ZStack so labels appearing don't shift the layout.
                            ZStack {
                                Circle()
                                    .fill(Color.brown.secondary)
                                    .frame(width: isWholeNumber ? 6 : 3, height: isWholeNumber ? 6 : 3)

                                if isWholeNumber {
                                    Text(String(format: "%.0f", value))
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.brown)
                                        .fixedSize()
                                        .offset(x: 32)
                                        .rotationEffect(angle)
                                }
                            }
                            .position(
                                x: center.x + cos(angle.radians) * radius,
                                y: center.y + sin(angle.radians) * radius
                            )
                            // The selected value sits at 0°, so it reads straight.
                            .rotationEffect(angle)
                        }
                    }
                }
                // Hide the left half of the dial, fading in only at the far right of that half.
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 22.0 / 23.0),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .center
                    )
                )

                // MARK: Center indicator
                HStack(spacing: 4) {
                    Capsule()
                        .fill(.brown.gradient)
                        .frame(width: 30, height: 3)
                    Circle()
                        .fill(.brown.gradient)
                        .frame(width: 8, height: 8)
                }
                .position(x: center.x + radius - 18, y: center.y)
            }
            .gesture(dragGesture)
            .onAppear {
                lastValueOnDragStart = tempoViewModel.tempo
            }
        }
        .frame(height: 350)
        .padding()
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        let range = TempoViewModel.minValue...TempoViewModel.maxValue
        let step = TempoViewModel.step
        return DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let valueChange = Double(gesture.translation.height) / scrollSensitivity
                let newValue = (lastValueOnDragStart - valueChange).clamped(to: range)

                if round(newValue / step) != round(tempoViewModel.tempo / step) {
                    impact.impactOccurred()
                }
                tempoViewModel.tempo = newValue
            }
            .onEnded { _ in
                let snappedValue = (round(tempoViewModel.tempo / step) * step).clamped(to: range)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    tempoViewModel.tempo = snappedValue
                }
                lastValueOnDragStart = snappedValue
            }
    }

    // MARK: - Helpers

    private func angle(for value: Double) -> Angle {
        .degrees((value - tempoViewModel.tempo) * anglePerUnit)
    }

    private func isAngleVisible(_ angle: Angle) -> Bool {
        (-100...100).contains(angle.degrees)
    }
}
