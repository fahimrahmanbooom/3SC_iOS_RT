//
//  PokemonHelper.swift
//  PokeApp
//
//  Created by Fahim Rahman on 11/5/25.
//

import SwiftUI

// extract pokemon id from the URL
struct PokemonHelper {
    static func extractPokemonID(from url: String) -> Int? {
        return Int(url.split(separator: "/").last ?? "")
    }
}
