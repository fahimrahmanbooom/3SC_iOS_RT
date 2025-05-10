//
//  PokemonDetailView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let detailURL: String
    @State private var detailsData: JSON = JSON()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    
                    if let spriteURL = self.detailsData.sprites.front_default.string,
                       let url = URL(string: spriteURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    Text(self.detailsData.name.string?.capitalized ?? "Loading...")
                        .font(.title).bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<(self.detailsData.stats.array?.count ?? 0), id: \.self) { index in
                            HStack {
                                Text(self.detailsData.stats[index].stat.name.string ?? "".capitalized)
                                
                                Spacer()
                                
                                Text("\(self.detailsData.stats[index].base_stat.int ?? 0)")
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
            }
            .navigationTitle(detailsData.name.string?.capitalized ?? "")
            .task {
                await loadData()
            }
        }
    }

    func loadData() async {
        NetworkCall.shared.fetchPokemonDetails(from: detailURL) { response in
            if let data = response {
                self.detailsData = try! JSON(data: data)
            }
        }
    }
}

#Preview {
    PokemonDetailView(detailURL: "https://pokeapi.co/api/v2/pokemon/1/")
}
