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

                    // MARK: - info
                    VStack(alignment: .leading, spacing: 8) {
                        
                        HStack {
                            Image(systemName: "ruler")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                            
                            Text("Height").bold()
                            
                            Spacer()
                            
                            Text(String(format: "%.1f m", Double(viewModel.selectedPokemonDetails.height.int ?? 0) / 10))
                        }
                        
                        HStack {
                            Image(systemName: "scalemass")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                            
                            Text("Weight").bold()
                            
                            Spacer()
                            
                            Text(String(format: "%.1f kg", Double(viewModel.selectedPokemonDetails.weight.int ?? 0) / 10))
                        }
                        
                        HStack {
                            Image(systemName: "burst")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                            
                            Text("Moves").bold()
                            
                            Spacer()
                            
                            Text(viewModel.selectedPokemonDetails.moves[0].move.name.string?.capitalized ?? "")
                        }
                        
                        HStack {
                            Image(systemName: "bolt")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                            
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

                    // MARK: - type
                    HStack {
                        Image(systemName: "cube")
                            .frame(width: 5)
                            .padding(.trailing, 5)
                        
                        Text("Type")
                            .bold()
                        
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

                    // MARK: - stats
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                                .padding([.leading, .bottom])
                            
                            Text("Stats")
                                .font(.headline)
                                .padding(.bottom)
                        }

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
                    
                    
                    // MARK: - evolution
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Image(systemName: "circle.grid.cross")
                                .frame(width: 5)
                                .padding(.trailing, 5)
                            
                            Text("Evolutions")
                                .font(.headline)
                        }
                        
                        if viewModel.evolutionChain.isEmpty {
                            Text("No evolution data.")
                                .foregroundColor(.gray)
                        } else {
                            let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
                            
                            LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
                                ForEach(0..<viewModel.evolutionChain.count, id: \.self) { index in
                                    
                                    let evo = viewModel.evolutionChain[index]
                                    let name = evo["name"].string ?? ""
                                    let id = Int(evo["url"].string?.split(separator: "/").last ?? "") ?? 0
                                    
                                    HStack(spacing: 8) {
                                        VStack(spacing: 6) {
                                            if let url = AppURL.shared.pokemonImageURL(pokemonID: id) {
                                                CachedAsyncImage(url: url, placeholder: { _ in
                                                    ProgressView()
                                                }, image: { image in
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .padding(5)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.orange.opacity(0.6), lineWidth: 1))
                                                })
                                            }
                                            
                                            Text(name.capitalized)
                                                .font(.caption)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                }
                .padding()
                .frame(width: geometry.size.width)
            }
            .onAppear {
                Task {
                    await viewModel.loadPokemonDetails(from: detailURL)
                    await viewModel.loadEvolutionChain(for: PokemonHelper.extractPokemonID(from: detailURL) ?? 0)
                }
            }
        }
        .clipped()
    }
}

#Preview {
    PokemonDetailView(detailURL: "https://pokeapi.co/api/v2/pokemon/6/")
}
