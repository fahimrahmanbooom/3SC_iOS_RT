//
//  PokemonListView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

//import SwiftUI
//import CachedAsyncImage
//
//struct PokemonListView: View {
//    
//    @StateObject private var viewModel = PokemonListViewModel()
//
//    var body: some View {
//        NavigationView {
//            GeometryReader { geometry in
//                List(viewModel.filteredPokemons.indices, id: \.self) { index in
//                    
//                    let pokemon = viewModel.filteredPokemons[index]
//                    
//                    NavigationLink(destination: PokemonDetailView(detailURL: pokemon.url.string ?? "")) {
//                        HStack {
//                            
//                            let pokemonID = extractPokemonID(from: pokemon["url"].string ?? "")
//                            
//                            CachedAsyncImage(url: AppURL.shared.pokemonImageURL(pokemonID: pokemonID ?? 0) ?? "", placeholder: { _ in
//                                    ProgressView()
//                                },
//                                image: {
//                                    Image(uiImage: $0)
//                                        .resizable()
//                                        .frame(width: 45, height: 45)
//                                        .clipShape(Circle())
//                                        .padding(5)
//                                        .overlay(Circle().stroke(Color.orange.opacity(0.5), lineWidth: 1, antialiased: true))
//                                        .padding(.trailing)
//                                }
//                            )
//                            
//                            Text(pokemon.name.string?.capitalized ?? "Unknown")
//                        }
//                        .onAppear {
//                            self.viewModel.loadMoreIfNeeded(currentItem: pokemon)
//                        }
//                    }
//                }
//                .scrollIndicators(.hidden)
//                .frame(width: geometry.size.width)
//            }
//            .navigationTitle("Pokémon")
//            .searchable(text: $viewModel.searchText)
//            .onAppear {
//                Task { await viewModel.loadInitial() }
//            }
//        }
//    }
//    
//    private func extractPokemonID(from url: String) -> Int? {
//        return Int(url.split(separator: "/").last ?? "")
//    }
//}
//
//#Preview {
//    PokemonListView()
//}


import SwiftUI
import CachedAsyncImage

struct PokemonListView: View {
    
    @StateObject private var viewModel = PokemonListViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List(viewModel.filteredPokemons.indices, id: \.self) { index in
                    
                    let pokemon = viewModel.filteredPokemons[index]
                    let pokemonID = extractPokemonID(from: pokemon["url"].string ?? "")

                    NavigationLink(destination: PokemonDetailView(detailURL: pokemon.url.string ?? "")) {
                        HStack(spacing: 16) {
                            ZStack {
                                // Static placeholder background (prevents layout jump)
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 45, height: 45)

                                CachedAsyncImage(
                                    url: AppURL.shared.pokemonImageURL(pokemonID: pokemonID ?? 0) ?? "",
                                    placeholder: { _ in EmptyView() },
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
                            .overlay(Circle().stroke(Color.orange.opacity(0.8), lineWidth: 1))
                            
                            Text(pokemon.name.string?.capitalized ?? "Unknown")
                            
                            Spacer()
                        }
                        .onAppear {
                            self.viewModel.loadMoreIfNeeded(currentItem: pokemon)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(width: geometry.size.width)
                //.listStyle(.plain)
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
