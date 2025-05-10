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
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(8)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1, antialiased: true))
                                .padding(.trailing)
                            
                            Text(pokemon.name.string?.capitalized ?? "Unknown")
                        }
                        .onAppear {
                            self.viewModel.loadMoreIfNeeded(currentItem: pokemon)
                        }
                    }
                }
                .scrollIndicators(.hidden)
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
