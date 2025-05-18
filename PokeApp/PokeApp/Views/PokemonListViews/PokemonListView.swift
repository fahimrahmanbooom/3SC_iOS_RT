//
//  PokemonListView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI

// pokemon list view
struct PokemonListView: View {
    
    @StateObject private var viewModel = PokemonListViewModel()
    @State private var overrideColorScheme: ColorScheme? = nil
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                List(viewModel.filteredPokemons, id: \.name.string) { pokemon in
                    let pokemonID = PokemonHelper.extractPokemonID(from: pokemon["url"].string ?? "")
                    let name = pokemon.name.string?.capitalized ?? "Unknown"
                    
                    NavigationLink(destination: PokemonDetailView(detailURL: pokemon.url.string ?? "")) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 45, height: 45)
                                
                                DiskCachingAsyncImage(url: URL(string: AppURL.shared.pokemonImageURL(pokemonID: pokemonID ?? 0) ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 45, height: 45)
                                        .padding(5)
                                        .clipShape(Circle())
                                        .transition(.opacity)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 45, height: 45)
                                        .padding(5)
                                        .background(Color.clear)
                                        .clipShape(Circle())
                                }
                            }
                            .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 2))
                            .accessibilityHidden(true)
                            
                            Text(name)
                                .font(.body)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .dynamicTypeSize(.small ... .xxLarge)
                                .accessibilityLabel("\(name) Pokémon")
                            
                            Spacer()
                        }
                        .accessibilityElement(children: .combine)
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(currentItem: pokemon)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(width: geometry.size.width)
            }
            .navigationTitle("Pokémon")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if overrideColorScheme == .dark {
                            overrideColorScheme = .light
                        } else {
                            overrideColorScheme = .dark
                        }
                    }) {
                        Image(systemName: overrideColorScheme == .dark ? "sun.max.fill" : "moon.fill")
                    }
                    .accessibilityLabel("Toggle dark mode")
                    .accessibilityHint("Switch between light and dark appearance")
                }
            }
            .onAppear {
                self.overrideColorScheme = systemColorScheme
                Task { await viewModel.loadInitial() }
            }
        }
        .preferredColorScheme(overrideColorScheme)
    }
}

#Preview {
    PokemonListView()
}
