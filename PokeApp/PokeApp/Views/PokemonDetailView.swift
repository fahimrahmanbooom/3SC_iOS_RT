//
//  PokemonDetailView.swift
//  PokeApp
//
//  Created by Fahim Rahman on 10/5/25.
//

import SwiftUI
import CachedAsyncImage

struct PokemonDetailView: View {
    
    let detailURL: String
    
    @State private var detailsData: JSON = JSON()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    
                    CachedAsyncImage(
                        url: self.detailsData.sprites.front_default.string ?? "",
                        placeholder: { _ in
                            ProgressView()
                                .frame(width: 150, height: 150)
                        },
                        image: {
                            Image(uiImage: $0)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .scaleEffect(1.5)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.yellow.opacity(0.5), lineWidth: 1))
                        }
                    )

                    
                    // Image
//                    if let spriteURL = self.detailsData.sprites.front_default.string,
//                       let url = URL(string: spriteURL) {
//                        CachedAsyncImage(url: url)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 150)
//                            .clipShape(Circle())
//                            .padding(8)
//                            .overlay(Circle().stroke(Color.gray, lineWidth: 1, antialiased: true))
//                            .padding(.trailing)
//                    }


//                    // Info box
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Height", value: "\(Double(detailsData.height.int ?? 0) / 10) m")
                        InfoRow(title: "Weight", value: "\(Double(detailsData.weight.int ?? 0) / 10) kg")
                        InfoRow(title: "Abilities", value: detailsData.abilities.array?.compactMap { $0.ability.name.string?.capitalized }.joined(separator: ", ") ?? "")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

//                    // Types
                    HStack {
                        Text("Type:")
                            .bold()
                        ForEach(0..<(self.detailsData.types.array?.count ?? 0), id: \.self) { index in
                            TypeBadgeView(type: self.detailsData.types[index].type.name.string ?? "")
                        }
                    }
//
//                    // Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stats").font(.headline)
                        ForEach(0..<(detailsData.stats.array?.count ?? 0), id: \.self) { index in
                            let stat = detailsData.stats[index]
                            StatBarView(label: stat.stat.name.string ?? "",
                                        value: stat.base_stat.int ?? 0)
                        }
                    }
                    
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
            .navigationTitle(detailsData.name.string?.capitalized ?? "")
            .task {
                await loadData()
            }
        }
    }

    @MainActor
    func loadData() async {
        NetworkCall.shared.fetchPokemonDetails(from: detailURL) { response in
            if let data = response {
                do {
                    self.detailsData = try JSON(data: data)
                } catch {
                    print("Failed to parse JSON: \(error)")
                }
            }
        }
    }
}

#Preview {
    PokemonDetailView(detailURL: "https://pokeapi.co/api/v2/pokemon/1/")
}


struct InfoRow: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title).bold()
            Spacer()
            Text(value)
        }
    }
}

struct TypeBadgeView: View {
    var type: String

    var body: some View {
        Text(type.capitalized)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(typeColor(type))
            .foregroundColor(.white)
            .cornerRadius(8)
    }

    func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
            case "grass": return .green
            case "poison": return .purple
            case "fire": return .orange
            case "water": return .blue
            case "psychic": return .pink
            case "flying": return .cyan
            case "electric": return .yellow
            default: return .gray
        }
    }
}

struct StatBarView: View {
    var label: String
    var value: Int

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label.capitalized)
                Spacer()
                Text("\(value)")
            }
            ProgressView(value: Float(value), total: 100)
                .tint(.blue)
        }
    }
}
