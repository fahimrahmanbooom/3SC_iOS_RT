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
                    .frame(width: UIDevice.isiPhone ? 55 : 85, height: UIDevice.isiPhone ? 55 : 85)

                Circle()
                    .trim(from: 0, to: CGFloat(min(Float(value) / 255, 1)))
                    .stroke(label.pokemonStatColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: UIDevice.isiPhone ? 55.5 : 85.5, height: UIDevice.isiPhone ? 55.5 : 85.5)

                Text("\(value)")
                    .font(UIDevice.isiPhone ? .caption : .subheadline)
                    .bold()
            }

            Text(label.capitalized)
                .font(UIDevice.isiPhone ? .caption2 : .subheadline)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatView(label: "Stat", value: 50)
}
