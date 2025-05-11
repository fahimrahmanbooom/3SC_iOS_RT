//
//  PokemonListViewModel.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import Foundation
import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
    
    @Published var pokemons: [JSON] = []
    @Published var filteredPokemons: [JSON] = []
    @Published var selectedPokemonDetails: JSON = JSON()
    @Published var searchText: String = ""
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private var offset = 0
    private let limit = 25
    private var isLoading = false
    private var canLoadMore = true

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applySearchFilter()
            }
            .store(in: &cancellables)
    }

    // private helper for filtering logic
    private func applySearchFilter() {
        filteredPokemons = searchText.isEmpty
            ? pokemons
            : pokemons.filter {
                $0.name.string?.lowercased().contains(searchText.lowercased()) ?? false
            }
    }

    // load initial data
    func loadInitial() async {
        if pokemons.isEmpty {
            await loadMore()
        }
    }

    // load more data
    func loadMore() async {
        guard !isLoading && canLoadMore else { return }
        isLoading = true

        if let data = await NetworkCall.shared.fetchPokemonList(offset: offset, limit: limit),
           let json = try? JSON(data: data) {

            let results = json.results.array ?? []
            if results.isEmpty { canLoadMore = false }

            pokemons.append(contentsOf: results)
            offset += limit

            applySearchFilter()
        }

        isLoading = false
    }
    
    // load more data for infinite scrolling
    func loadMoreIfNeeded(currentItem: JSON?) async {
        guard let currentItem = currentItem else {
            await loadMore()
            return
        }
        if let index = pokemons.firstIndex(of: currentItem),
           index >= pokemons.count - 5 {
            await loadMore()
        }
    }
    
    // load pokemon details
    func loadPokemonDetails(from url: String) async {
        if let data = await NetworkCall.shared.fetchPokemonDetails(from: url) {
            do {
                self.selectedPokemonDetails = try JSON(data: data)
            } catch {
                print("Failed to parse JSON: \(error)")
                self.errorMessage = "Failed to load details."
            }
        } else {
            self.errorMessage = "Failed to fetch Pokémon details."
        }
    }
}
