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

    @State private var scrollPosition: Double?

    init(allValues: [Double], selectedValue: Binding<Double>) {
        self.allValues = allValues
        self._selectedValue = selectedValue
        // Start already scrolled to the current value. Setting it in onAppear rendered one
        // frame at the start of the ruler first, flashing the ticks near the value at the edge.
        self._scrollPosition = State(initialValue: selectedValue.wrappedValue)
    }

    /// Near either end of the range, pad the row so the first/last tick can still reach the center arrow.
    private var needsEdgePadding: Bool {
        selectedValue < TempoViewModel.minValue + 2 || selectedValue > TempoViewModel.maxValue - 2
    }

    var body: some View {
        GeometryReader { geometry in
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
                    LazyHStack(alignment: .top, spacing: 10) {
                        ForEach(allValues, id: \.self) { value in
                            TickLabel(value: value, selectedValue: selectedValue)
                                .containerRelativeFrame(.horizontal, count: 12, spacing: 0)
                                .id(value)
                        }
                    }
                    .padding(.horizontal, needsEdgePadding ? (geometry.size.width / 2) - 15 : 0)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition, anchor: .top)
                .onChange(of: scrollPosition) { _, newValue in
                    if let newValue {
                        withAnimation {
                            selectedValue = newValue
                        }
                    }
                }
                .padding(.top)
            }
        }
        .frame(maxWidth: 350)
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
