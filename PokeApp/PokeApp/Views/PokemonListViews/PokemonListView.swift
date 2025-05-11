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
                    let pokemonID = PokemonHelper.extractPokemonID(from: pokemon["url"].string ?? "")

                    NavigationLink(destination: PokemonDetailView(detailURL: pokemon.url.string ?? "")) {
                        HStack(spacing: 16) {
                            ZStack {
                                
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 45, height: 45)

                                CachedAsyncImage(
                                    url: AppURL.shared.pokemonImageURL(pokemonID: pokemonID ?? 0) ?? "",
                                    placeholder: { _ in
                                        ProgressView()
                                            .frame(width: 45, height: 45)
                                    },
                                    image: {
                                        Image(uiImage: $0)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 45, height: 45)
                                            .padding(5)
                                            .clipShape(Circle())
                                            .transition(.opacity)
                                    }
                                )
                            }
                            .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 2))
                            
                            Text(pokemon.name.string?.capitalized ?? "Unknown")
                            
                            Spacer()
                        }
                        .onAppear {
                            Task {
                                await self.viewModel.loadMoreIfNeeded(currentItem: pokemon)
                            }
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
}

#Preview {
    PokemonListView()
}
