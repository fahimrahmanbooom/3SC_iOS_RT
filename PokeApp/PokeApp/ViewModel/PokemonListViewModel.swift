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
    @Published var evolutionChain: [JSON] = []
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

    // MARK: - Search Filtering
    private func applySearchFilter() {
        filteredPokemons = searchText.isEmpty ? pokemons : pokemons.filter {
            $0.name.string?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }

    // MARK: - Initial Load
    func loadInitial() async {
        if pokemons.isEmpty {
            await loadMore()
        }
    }

    // MARK: - Load More Pokémons (Pagination)
    func loadMore() async {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        defer { isLoading = false }

        guard let data = await NetworkCall.shared.fetchPokemonList(offset: offset, limit: limit) else {
            errorMessage = "Failed to fetch Pokémon list."
            return
        }

        do {
            let json = try JSON(data: data)
            let results = json["results"].array ?? []

            if results.isEmpty {
                canLoadMore = false
            }

            pokemons.append(contentsOf: results)
            offset += limit
            applySearchFilter()
        } catch {
            print("❌ JSON parse error: \(error)")
            errorMessage = "Failed to parse Pokémon list."
        }
    }

    // MARK: - Load More When Needed
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

    // MARK: - Load Pokémon Details
    func loadPokemonDetails(from url: String) async {
        guard let data = await NetworkCall.shared.fetchPokemonDetails(from: url) else {
            errorMessage = "Failed to fetch Pokémon details."
            return
        }

        do {
            self.selectedPokemonDetails = try JSON(data: data)
        } catch {
            print("❌ Failed to parse Pokémon details: \(error)")
            self.errorMessage = "Failed to load details."
        }
    }

    @MainActor
    func loadEvolutionChain(for pokemonID: Int) async {
        guard let speciesURL = AppURL.shared.pokemonSpeciesURL(pokemonID: pokemonID) else {
            print("❌ Invalid species URL")
            return
        }

        // Step 1: Fetch species data
        guard let speciesData = await NetworkCall.shared.fetchPokemonDetails(from: speciesURL) else {
            print("❌ Failed to fetch species data")
            return
        }

        guard let speciesJSON = try? JSON(data: speciesData) else {
            print("❌ Failed to parse species JSON")
            return
        }

        guard let evoURL = speciesJSON["evolution_chain"]["url"].string else {
            print("❌ Evolution chain URL not found in species JSON")
            return
        }

        // Step 2: Fetch evolution chain
        guard let evoData = await NetworkCall.shared.fetchPokemonDetails(from: evoURL) else {
            print("❌ Failed to fetch evolution chain data")
            return
        }

        guard let evoJSON = try? JSON(data: evoData) else {
            print("❌ Failed to parse evolution chain JSON")
            return
        }

        // Step 3: Traverse the chain recursively
        var collectedChain: [JSON] = []

        func traverse(_ node: JSON) {
            if let species = node["species"].dictionary {
                collectedChain.append(JSON(species))
            }

            for evolution in node["evolves_to"].array ?? [] {
                traverse(evolution)
            }
        }

        traverse(evoJSON["chain"])
        self.evolutionChain = collectedChain
    }
}
