//
//  StatView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import SwiftUI

struct StatView: View {
    
    var label: String
    var value: Int

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(label.pokemonStatColor.opacity(0.3), lineWidth: 6)
                    .frame(width: 55, height: 55)

                Circle()
                    .trim(from: 0, to: CGFloat(min(Float(value) / 255, 1)))
                    .stroke(label.pokemonStatColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 55.5, height: 55.5)

                Text("\(value)")
                    .font(.caption)
                    .bold()
            }

            Text(label.capitalized)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatView(label: "Stat", value: 50)
}
