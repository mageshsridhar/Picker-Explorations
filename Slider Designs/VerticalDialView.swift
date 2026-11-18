//
//  VerticalDialView.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

/// "Minimal": a wheel picker styled as a vertical ruler.
struct VerticalDialView: View {
    @EnvironmentObject var tempoViewModel: TempoViewModel

    var body: some View {
        SnapDialWindow(value: $tempoViewModel.tempo)
            .frame(width: 250, height: 120)
            .padding()
    }
}

struct SnapDialWindow: View {
    @Binding var value: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brown.gradient.opacity(0.15))
                .stroke(.brown.secondary, lineWidth: 1)
            Rectangle()
                .fill(.brown.tertiary)
                .frame(maxWidth: 2, maxHeight: .infinity)
                .offset(x: 40)

            // Overlay so the wheel's natural height doesn't resize the window.
            Color.clear
                .overlay(
                    HStack {
                        Spacer()
                        Picker("Value", selection: $value) {
                            ForEach(TempoViewModel.allValues, id: \.self) { tickValue in
                                TickRowView(value: tickValue)
                                    .tag(tickValue)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 130)
                        .clipped()
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Fixed indicator in the center
            ArrowShape()
                .fill(Color.brown.gradient)
                .frame(width: 20, height: 20)
                .offset(x: 25)

            // Value display in the top-leading corner
            VStack(alignment: .leading, spacing: 2) {
                Text("Tempo (bpm)")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.brown)
                Text("\(value, specifier: "%.1f")")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .contentTransition(.numericText())
                    .animation(.spring, value: value)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(12)
        }
    }
}

struct TickRowView: View {
    let value: Double

    private var isWholeNumber: Bool {
        value.truncatingRemainder(dividingBy: 1) == 0
    }

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(isWholeNumber ? .brown : .brown.opacity(0.7))
                .frame(width: isWholeNumber ? 30 : 18, height: 2)

            // Half-step rows keep an invisible label so spacing stays even.
            Text("\(Int(value))")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.brown)
                .opacity(isWholeNumber ? 1 : 0)
            Spacer()
        }
        .offset(x: 45)
    }
}
