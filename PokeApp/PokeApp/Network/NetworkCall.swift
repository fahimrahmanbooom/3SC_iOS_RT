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
    private init() {}

    // Fetch Pokémon list with pagination
    func fetchPokemonList(offset: Int, limit: Int) async -> Data? {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)") else {
            print("❌ Invalid Pokémon list URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                return nil
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Status Code: \(httpResponse.statusCode)")
                return nil
            }

            guard httpResponse.mimeType == "application/json" else {
                let raw = String(data: data, encoding: .utf8) ?? "Unreadable response"
                print("❌ Unexpected MIME type: \(httpResponse.mimeType ?? "nil")")
                print("❌ Raw response: \(raw)")
                return nil
            }

            return data
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            return nil
        }
    }

    // Generic fetch for Pokémon detail or species or evolution
    func fetchPokemonDetails(from url: String) async -> Data? {
        guard let url = URL(string: url) else {
            print("❌ Invalid detail URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                return nil
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Status Code: \(httpResponse.statusCode)")
                return nil
            }

            guard httpResponse.mimeType == "application/json" else {
                let raw = String(data: data, encoding: .utf8) ?? "Unreadable response"
                print("❌ Unexpected MIME type: \(httpResponse.mimeType ?? "nil")")
                print("❌ Raw response: \(raw)")
                return nil
            }

            return data
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            return nil
        }
    }
}
