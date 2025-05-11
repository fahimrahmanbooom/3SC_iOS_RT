//
//  StatView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import SwiftUI

// statistics view for the pokemons
struct StatView: View {
    
    var label: String
    var value: Int

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(label.pokemonStatColor.opacity(0.3), lineWidth: 6)
                    .frame(width: UIDevice.isiPhone ? 55 : 85, height: UIDevice.isiPhone ? 55 : 85)

                Circle()
                    .trim(from: 0, to: CGFloat(min(Float(value) / 255, 1)))
                    .stroke(label.pokemonStatColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: UIDevice.isiPhone ? 55.5 : 85.5, height: UIDevice.isiPhone ? 55.5 : 85.5)

                Text("\(value)")
                    .font(UIDevice.isiPhone ? .caption : .subheadline)
                    .bold()
                    .dynamicTypeSize(.small ... .xxLarge)
            }

            Text(label.capitalized)
                .font(UIDevice.isiPhone ? .caption2 : .subheadline)
                .dynamicTypeSize(.small ... .large)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label.capitalized): \(value)")
    }
}

#Preview {
    StatView(label: "Speed", value: 87)
}
