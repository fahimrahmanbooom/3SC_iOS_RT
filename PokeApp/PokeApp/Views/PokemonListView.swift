//
//  PokemonListView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI
import CachedAsyncImage

struct PokemonListView: View {
    
    @StateObject private var viewModel = PokemonListViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List(viewModel.filteredPokemons.indices, id: \.self) { index in
                    let pokemon = viewModel.filteredPokemons[index]
                    NavigationLink(destination: PokemonDetailView(detailURL: pokemon.url.string ?? "")) {
                        HStack {
                            
                            let pokemonID = extractPokemonID(from: pokemon["url"].string ?? "")
                            
                            CachedAsyncImage(url: AppURL.shared.pokemonImageURL(pokemonID: pokemonID ?? 0) )
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.orange.opacity(0.5), lineWidth: 1, antialiased: true))
                                .padding(.trailing)
                            
                            Text(pokemon.name.string?.capitalized ?? "Unknown")
                        }
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: pokemon)
                        }
                    }
                }
                .frame(width: geometry.size.width)
            }
            .navigationTitle("Pokémon")
            .searchable(text: $viewModel.searchText)
            .onAppear {
                Task { await viewModel.loadInitial() }
            }
        }
    }
    
    private func extractPokemonID(from url: String) -> Int? {
        return Int(url.split(separator: "/").last ?? "")
    }
}

#Preview {
    PokemonListView()
}
