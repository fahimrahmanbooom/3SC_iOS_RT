//
//  NetworkCall.swift
//  PokeApp
//
//  Created by Fahim Rahman on 9/5/25.
//

import Foundation
import Alamofire

final class NetworkCall {

    static let shared = NetworkCall()
    private init() { }

    private let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]

    // MARK: - fetch Pokemon List
    func fetchPokemonList(offset: Int = 0, limit: Int = 20, completion: @escaping (Data?) -> Void) {
        guard let url = AppURL.shared.pokemonListURL(offset: offset, limit: limit)?.absoluteString else {
            print("❌ Invalid Pokemon list URL")
            completion(nil)
            return
        }

        NetworkManager.shared.requestRaw(url: url, method: .get, headers: headers) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("❌ Failed to fetch Pokemon list:", error.localizedDescription)
                completion(nil)
            }
        }
    }

    // MARK: - fetch Pokemon Details
    func fetchPokemonDetails(from detailURL: String, completion: @escaping (Data?) -> Void) {
        NetworkManager.shared.requestRaw(url: detailURL, method: .get, headers: headers) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("❌ Failed to fetch Pokemon details:", error.localizedDescription)
                completion(nil)
            }
        }
    }
}
