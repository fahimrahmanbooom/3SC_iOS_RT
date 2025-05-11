//
//  PokemonListViewModel.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import Foundation
import Combine

class PokemonListViewModel: ObservableObject {
    
    @Published var pokemons: [JSON] = []
    @Published var searchText: String = ""
    @Published var filteredPokemons: [JSON] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var offset = 0
    private let limit = 20
    private var isLoading = false
    private var canLoadMore = true

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] search in
                guard let self = self else { return }
                if search.isEmpty {
                    self.filteredPokemons = self.pokemons
                } else {
                    self.filteredPokemons = self.pokemons.filter {
                        $0.name.string?.lowercased().contains(search.lowercased()) ?? false
                    }
                }
            }
            .store(in: &cancellables)
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
                    self.filteredPokemons = self.searchText.isEmpty
                        ? self.pokemons
                        : self.pokemons.filter {
                            $0.name.string?.lowercased().contains(self.searchText.lowercased()) ?? false
                        }
                }
                self.isLoading = false
            }
        }
    }
}
