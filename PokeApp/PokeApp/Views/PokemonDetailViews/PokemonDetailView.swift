//
//  PokemonDetailView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI
import CachedAsyncImage

struct PokemonDetailView: View {
 
    @StateObject private var viewModel = PokemonListViewModel()
    
    let detailURL: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    HStack {
                        Text(viewModel.selectedPokemonDetails.name.string?.capitalized ?? "")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color.orange)
                        
                        Text(viewModel.selectedPokemonDetails.base_experience.string ?? "")
                            .bold()
                    }
                    
                    if let id = PokemonHelper.extractPokemonID(from: detailURL),
                       let url = AppURL.shared.pokemonImageURL(pokemonID: id) {
                        
                        CachedAsyncImage(url: url, placeholder: { _ in
                                ProgressView()
                                    .frame(width: 150, height: 150)
                            },
                            image: {
                                Image(uiImage: $0)
                                    .resizable()
                                    .scaledToFit()
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                                    .frame(width: 120, height: 120)
                                    .padding(15)
                                    .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 1))
                                    .padding(.bottom, 30)
                            }
                        )
                    }

                    // info
                    VStack(alignment: .leading, spacing: 8) {
                        
                        HStack {
                            Text("Height").bold()
                            Spacer()
                            Text(String(format: "%.1f m", Double(viewModel.selectedPokemonDetails.height.int ?? 0) / 10))
                        }
                        
                        HStack {
                            Text("Weight").bold()
                            Spacer()
                            Text(String(format: "%.1f kg", Double(viewModel.selectedPokemonDetails.weight.int ?? 0) / 10))
                        }
                        
                        HStack {
                            Text("Moves").bold()
                            Spacer()
                            Text(viewModel.selectedPokemonDetails.moves[0].move.name.string?.capitalized ?? "")
                        }
                        
                        HStack {
                            Text("Abilities").bold()
                            Spacer()
                            let abilitiesArray = viewModel.selectedPokemonDetails.abilities.array ?? []
                            let abilityNames = abilitiesArray.compactMap { $0.ability.name.string?.capitalized }
                            let abilitiesText = abilityNames.joined(separator: ", ")
                            Text(abilitiesText)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)

                    // type
                    HStack {
                        Text("Type")
                            .bold()
                            .padding(.trailing)
                        
                        Spacer()
                        
                        ForEach(0..<(self.viewModel.selectedPokemonDetails.types.array?.count ?? 0), id: \.self) { index in
                            
                            Text(self.viewModel.selectedPokemonDetails.types[index].type.name.string?.capitalized ?? "")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(self.viewModel.selectedPokemonDetails.types[index].type.name.string?.pokemonTypeColor ?? .gray)
                                .foregroundStyle(Color.black)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)

                    // stats
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Stats")
                            .font(.headline)
                            .padding([.leading, .bottom])

                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<(viewModel.selectedPokemonDetails.stats.array?.count ?? 0), id: \.self) { index in
                                let stat = viewModel.selectedPokemonDetails.stats[index]
                                StatView(label: stat.stat.name.string ?? "", value: stat.base_stat.int ?? 0)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    // Placeholder for evolutions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Evolutions")
                            .font(.headline)
                        Text("Evolution data needs species API → chain.")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
            }
            .task { await viewModel.loadPokemonDetails(from: detailURL) }
        }
        .clipped()
    }
}

#Preview {
    PokemonDetailView(detailURL: "https://pokeapi.co/api/v2/pokemon/1/")
}
