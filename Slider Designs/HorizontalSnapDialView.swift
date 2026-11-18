//
//  HorizontalSnapDialView.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

/// "Sleek": a horizontal ruler that snaps to each tick.
struct HorizontalSnapDialView: View {
    @EnvironmentObject var tempoViewModel: TempoViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Tempo (bpm)")
                .font(.footnote)
                .bold()
                .foregroundStyle(.brown)
            Text("\(tempoViewModel.tempo, specifier: "%.1f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: tempoViewModel.tempo)

            ScrollableSnapDial(
                allValues: TempoViewModel.allValues,
                selectedValue: $tempoViewModel.tempo
            )
            .padding(.top, 20)
            .frame(height: 100)
        }
        .padding(.top)
        .background(RoundedRectangle(cornerRadius: 30).fill(.brown.gradient.quinary))
        .clipped()
    }
}

struct ScrollableSnapDial: View {
    let allValues: [Double]
    @Binding var selectedValue: Double

    /// Space between neighbouring ticks.
    private let tickSpacing: CGFloat = 10

    @State private var position = ScrollPosition(x: 0)
    /// True while the user drags or the ruler is still settling; only then does scrolling
    /// change the tempo, so positioning the ruler programmatically never does.
    @State private var isScrolling = false
    /// Latest scroll offset, measured from the first tick sitting under the arrow.
    @State private var offset: CGFloat = 0
    /// The ruler stays hidden until it's scrolled to the current tempo, so it never shows
    /// a frame at the wrong place (which used to flash ticks at the edge).
    @State private var isPositioned = false

    var body: some View {
        GeometryReader { geometry in
            // Twelve ticks across the ruler.
            let tickWidth = geometry.size.width / 12
            let step = tickWidth + tickSpacing
            ZStack {
                ArrowShape()
                    .fill(.brown.gradient)
                    .frame(width: 20, height: 30)
                    .rotationEffect(Angle(degrees: 90))
                    .offset(y: -50)
                Rectangle()
                    .frame(height: 1)
                    .offset(y: -35)
                    .foregroundStyle(.brown.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    // Not lazy: 281 small ticks are cheap, and exact geometry lets the ruler open at
                    // the right offset (a lazy stack only estimates its width before layout).
                    HStack(alignment: .top, spacing: tickSpacing) {
                        ForEach(allValues, id: \.self) { value in
                            TickLabel(value: value, selectedValue: selectedValue)
                                .frame(width: tickWidth)
                        }
                    }
                    .scrollTargetLayout()
                }
                // Half the ruler less half a tick on each side, so every tick (the first and
                // last included) snaps to the center under the arrow. These margins never
                // change, so the content doesn't shift mid-scroll as the old edge padding did.
                .contentMargins(.horizontal, (geometry.size.width - tickWidth) / 2, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition($position)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.x + geometry.contentInsets.leading
                } action: { _, newOffset in
                    offset = newOffset
                    if isScrolling { updateValue(step: step) }
                }
                .onScrollPhaseChange { _, phase in
                    isScrolling = phase != .idle
                    // Catch the final snapped position once scrolling settles.
                    if phase == .idle { updateValue(step: step) }
                }
                .opacity(isPositioned ? 1 : 0)
                .onAppear {
                    let index = allValues.firstIndex(of: selectedValue) ?? 0
                    // Offsets count from the first tick centered under the arrow.
                    position.scrollTo(x: CGFloat(index) * step)
                    isPositioned = true
                }
                .padding(.top)
            }
        }
        .frame(maxWidth: 350)
    }

    /// Sets the tempo to the tick nearest the arrow.
    private func updateValue(step: CGFloat) {
        guard isPositioned, step > 0 else { return }
        let index = min(max(Int((offset / step).rounded()), 0), allValues.count - 1)
        let value = allValues[index]
        if value != selectedValue {
            withAnimation { selectedValue = value }
        }
    }
}

struct TickLabel: View {
    let value: Double
    let selectedValue: Double

    private var isWholeNumber: Bool {
        value.truncatingRemainder(dividingBy: 1) == 0
    }

    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(isWholeNumber ? Color.brown : Color.gray.opacity(0.5))
                .frame(width: 2, height: isWholeNumber ? 20 : 10)

            // Half-step ticks keep an invisible label so every column has the same height.
            Text("\(Int(value))")
                .font(isWholeNumber ? .subheadline.bold().monospaced() : .footnote)
                .foregroundStyle(.brown)
                .opacity(isWholeNumber ? 1 : 0)
        }
        .rotationEffect(angle, anchor: .bottom)
        .opacity(opacity)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedValue)
    }

    /// Ticks within 4 bpm of the selection fan out up to ±60°.
    private var angle: Angle {
        let maxDistance = 4.0
        let maxAngle = 60.0
        let difference = value - selectedValue
        guard abs(difference) <= maxDistance else { return .zero }
        return .degrees((difference / maxDistance) * maxAngle)
    }

    private var opacity: Double {
        max(0, 1 - abs(value - selectedValue) * 0.4)
    }
}
