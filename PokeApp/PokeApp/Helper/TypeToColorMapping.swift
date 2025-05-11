//
//  TypeToColorMapping.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI

extension String {
    // pokemon type color for type background
    var pokemonTypeColor: Color {
        let typeColors: [String: Color] = [
            "grass": .green,
            "poison": .purple,
            "fire": .orange,
            "water": .blue,
            "electric": .yellow,
            "ice": .cyan,
            "psychic": .pink,
            "normal": .gray,
            "flying": .teal,
            "bug": .mint,
            "ground": .brown,
            "rock": .indigo,
            "ghost": .purple,
            "dragon": .red,
            "dark": .secondary,
            "steel": .gray,
            "fairy": .pink
        ]
        return typeColors[self.lowercased()] ?? .gray
    }
    
    // pokemon stat color for progress view
    var pokemonStatColor: Color {
        let statColors: [String: Color] = [
            "hp": .red,
            "attack": .orange,
            "defense": .yellow,
            "special-attack": .blue,
            "special-defense": .mint,
            "speed": .purple
        ]
        return statColors[self.lowercased()] ?? .gray
    }
}
