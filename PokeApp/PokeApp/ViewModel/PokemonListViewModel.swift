//
//  PokemonListViewModel.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import Foundation

class PokemonListViewModel: ObservableObject {
    
    @Published var pokemons: [JSON] = []
    @Published var searchText: String = ""

    private var offset = 0
    private let limit = 20
    private var isLoading = false
    private var canLoadMore = true

    var filteredPokemons: [JSON] {
        if searchText.isEmpty { return pokemons }
        return pokemons.filter {
            $0.name.string?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }

    func loadInitial() async {
        if pokemons.isEmpty {
            await loadMore()
        }
    }

    func loadMoreIfNeeded(currentItem: JSON?) {
        guard let currentItem = currentItem else {
            Task { await loadMore() }
            return
        }
        if let index = pokemons.firstIndex(of: currentItem),
           index >= pokemons.count - 5 {
            Task { await loadMore() }
        }
    }

    @MainActor
    func loadMore() async {
        guard !isLoading && canLoadMore else { return }
        isLoading = true

        NetworkCall.shared.fetchPokemonList(offset: offset, limit: limit) { response in
            DispatchQueue.main.async {
                if let data = response, let json = try? JSON(data: data) {
                    let results = json.results.array ?? []
                    if results.isEmpty { self.canLoadMore = false }
                    self.pokemons.append(contentsOf: results)
                    self.offset += self.limit
                }
                self.isLoading = false
            }
        }
    }
}
