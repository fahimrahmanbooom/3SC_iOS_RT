//
//  NetworkCall.swift
//  PokeApp
//
//  Created by Fahim Rahman on 9/5/25.
//

import Foundation

@MainActor
final class NetworkCall {

    static let shared = NetworkCall()
    private init() { }

    // MARK: - fetch pokemon list
    func fetchPokemonList(offset: Int = 0, limit: Int = 25) async -> Data? {
        guard let url = AppURL.shared.pokemonListURL(offset: offset, limit: limit) else {
            print("❌ Invalid Pokemon list URL")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("❌ Failed to fetch Pokemon list:", error.localizedDescription)
            return nil
        }
    }

    // MARK: - fetch pokemon details
    func fetchPokemonDetails(from detailURL: String) async -> Data? {
        guard let url = URL(string: detailURL) else {
            print("❌ Invalid detail URL")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("❌ Failed to fetch Pokemon details:", error.localizedDescription)
            return nil
        }
    }

    // MARK: - fetch volution chain data
    func fetchEvolutionChainData(pokemonID: Int) async -> Data? {
        guard let speciesURL = AppURL.shared.pokemonSpeciesURL(pokemonID: pokemonID) else {
            print("❌ Invalid species URL")
            return nil
        }

        do {
            let (speciesData, _) = try await URLSession.shared.data(from: speciesURL)

            guard
                let json = try JSONSerialization.jsonObject(with: speciesData) as? [String: Any],
                let evoInfo = json["evolution_chain"] as? [String: Any],
                let evoURLString = evoInfo["url"] as? String,
                let evoURL = URL(string: evoURLString)
            else {
                print("❌ Could not parse evolution_chain URL from species data")
                return nil
            }

            let (evoData, _) = try await URLSession.shared.data(from: evoURL)
            return evoData

        } catch {
            print("❌ Error fetching evolution chain:", error.localizedDescription)
            return nil
        }
    }
}
