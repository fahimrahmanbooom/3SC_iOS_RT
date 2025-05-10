//
//  AppURL.swift
//  PokeApp
//
//  Created by Fahim Rahman on 9/5/25.
//

import Foundation

final class AppURL {
    
    static let shared = AppURL()
    private init() {}

    // base URL
    private let baseURL = "https://pokeapi.co/api/v2/"

    // pokemon list with pagination
    func pokemonListURL(offset: Int = 0, limit: Int = 20) -> URL? {
        return URL(string: "\(baseURL)pokemon?offset=\(offset)&limit=\(limit)")
    }

    // pokemon detail URL
    func pokemonDetailURL(from path: String) -> URL? {
        return URL(string: path)
    }
    
    // pokemon image URL
    func pokemonImageURL(pokemonID: Int) -> URL? {
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png")
    }
}
