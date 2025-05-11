//
//  PokemonDetailView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI

// pokemon details view
struct PokemonDetailView: View {
    
    @StateObject private var viewModel = PokemonListViewModel()
    
    let detailURL: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Name and Experience
                    HStack {
                        Text(viewModel.selectedPokemonDetails.name.string?.capitalized ?? "")
                            .font(.title2)
                            .bold()
                            .dynamicTypeSize(.small ... .xxLarge)
                            .accessibilityLabel("Pokémon name: \(viewModel.selectedPokemonDetails.name.string?.capitalized ?? "Unknown")")
                        
                        Spacer()
                        
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color.orange)
                            .accessibilityHidden(true)
                        
                        Text(viewModel.selectedPokemonDetails.base_experience.string ?? "")
                            .bold()
                            .dynamicTypeSize(.small ... .xxLarge)
                            .accessibilityLabel("Base experience: \(viewModel.selectedPokemonDetails.base_experience.string ?? "0")")
                    }
                    .accessibilityElement(children: .combine)
                    
                    // MARK: - Image
                    if let id = PokemonHelper.extractPokemonID(from: detailURL),
                       let url = AppURL.shared.pokemonImageURL(pokemonID: id) {
                        
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                                .frame(width: UIDevice.isiPhone ? 120 : 150, height: UIDevice.isiPhone ? 120 : 150)
                                .padding(15)
                                .overlay(Circle().stroke(Color.blue.opacity(0.6), lineWidth: 1))
                                .padding(.bottom, 30)
                                .accessibilityLabel("Pokémon image")
                        } placeholder: {
                            ProgressView()
                                .frame(width: UIDevice.isiPhone ? 150 : 200, height: UIDevice.isiPhone ? 150 : 200)
                        }
                    }
                    
                    // MARK: - Info Section
                    VStack(alignment: .leading, spacing: UIDevice.isiPhone ? 8 : 12) {
                        
                        infoRow(icon: "ruler", label: "Height", value: String(format: "%.1f m", Double(viewModel.selectedPokemonDetails.height.int ?? 0) / 10))
                        
                        infoRow(icon: "scalemass", label: "Weight", value: String(format: "%.1f kg", Double(viewModel.selectedPokemonDetails.weight.int ?? 0) / 10))
                        
                        infoRow(icon: "burst", label: "Moves", value: viewModel.selectedPokemonDetails.moves[0].move.name.string?.capitalized ?? "Unknown")
                        
                        let abilitiesArray = viewModel.selectedPokemonDetails.abilities.array ?? []
                        let abilityNames = abilitiesArray.compactMap { $0.ability.name.string?.capitalized }
                        let abilitiesText = abilityNames.joined(separator: ", ")
                        
                        infoRow(icon: "bolt", label: "Abilities", value: abilitiesText)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                    
                    // MARK: - Types
                    HStack {
                        Image(systemName: "cube")
                            .accessibilityHidden(true)
                        
                        Text("Type")
                            .bold()
                            .dynamicTypeSize(.small ... .xxLarge)
                        
                        Spacer()
                        
                        ForEach(0..<(self.viewModel.selectedPokemonDetails.types.array?.count ?? 0), id: \.self) { index in
                            let typeName = self.viewModel.selectedPokemonDetails.types[index].type.name.string?.capitalized ?? ""
                            
                            Text(typeName)
                                .font(.caption)
                                .bold()
                                .dynamicTypeSize(.small ... .large)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(self.viewModel.selectedPokemonDetails.types[index].type.name.string?.pokemonTypeColor ?? .gray)
                                .foregroundStyle(Color.black)
                                .cornerRadius(8)
                                .accessibilityLabel("Type: \(typeName)")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    
                    // MARK: - Stats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .accessibilityHidden(true)
                            
                            Text("Stats")
                                .font(.headline)
                                .dynamicTypeSize(.small ... .xxLarge)
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
                                    .accessibilityLabel("\(stat.stat.name.string?.capitalized ?? ""): \(stat.base_stat.int ?? 0)")
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    // MARK: - Evolution
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "circle.grid.cross")
                                .accessibilityHidden(true)
                            
                            Text("Evolutions")
                                .font(.headline)
                                .dynamicTypeSize(.small ... .xxLarge)
                        }
                        
                        if viewModel.evolutionChain.isEmpty {
                            Text("No evolution data.")
                                .foregroundColor(.gray)
                                .accessibilityLabel("No evolution data available")
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
                                                AsyncImage(url: URL(string: url)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .padding(5)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.orange.opacity(0.6), lineWidth: 1))
                                                        .accessibilityLabel("Evolution: \(name.capitalized)")
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                            
                                            Text(name.capitalized)
                                                .font(.caption)
                                                .dynamicTypeSize(.small ... .large)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .accessibilityHidden(true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
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
    
    // MARK: - Helper for Info Rows
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 5)
                .padding(.trailing, 5)
                .accessibilityHidden(true)
            
            Text(label).bold()
                .dynamicTypeSize(.small ... .xxLarge)
            
            Spacer()
            
            Text(value)
                .dynamicTypeSize(.small ... .xxLarge)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    PokemonDetailView(detailURL: "https://pokeapi.co/api/v2/pokemon/6/")
}
