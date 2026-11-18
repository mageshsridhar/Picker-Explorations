//
//  ContentView.swift
//  Slider Designs
//
//  Created by Magesh Sridhar on 8/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: SliderView = .minimal
    @StateObject private var tempoViewModel = TempoViewModel()
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Picker Explorations")
                    .font(.title3)
                    .bold()
                Picker("", selection: $selection) {
                    ForEach(SliderView.allCases, id: \.self) { sliderView in
                        Text(sliderView.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Group {
                    switch selection {
                    case .minimal: VerticalDialView()
                    case .sleek: HorizontalSnapDialView()
                    case .modern: SemiCircleDialView()
                    }
                }
                .transition(.slide.combined(with: .opacity))
                .frame(maxHeight: 400)
                .environmentObject(tempoViewModel)
                Text("Designed and Built by Magesh Sridhar using SwiftUI 🤎")
                    .font(.footnote)
            }
            // Fills narrow screens (iPhone) but stays 500 pt wide on larger ones.
            .frame(maxWidth: 500)
            .frame(height: 500)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.brown.quaternary, lineWidth: 1))
            .animation(.easeInOut, value: selection)
            .padding()
        }
    }
}

enum SliderView: String, CaseIterable {
    case minimal = "Minimal"
    case sleek = "Sleek"
    case modern = "Modern"
}

#Preview {
    ContentView()
}
