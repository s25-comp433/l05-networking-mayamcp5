//
//  ContentView.swift
//  BasketballGames
//
//  Created by Samuel Shi on 2/27/25.
//

import SwiftUI

struct Result: Codable {
    var team: String
    var id: Int
    var date: String
    var score: Score
    var isHomeGame: Bool
    var opponent: String
}

struct Score: Codable {
    var unc: Int
    var opponent: Int
}

struct ContentView: View {
    @State private var results = [Result]()

    var body: some View {
        NavigationStack {
            List(results, id: \.id) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(item.team) vs. \(item.opponent)").font(.headline)
                        Text(item.date).font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(item.score.unc) - \(item.score.opponent)").font(.headline).foregroundStyle(scoreColor(for: item))
                        Text(item.isHomeGame ? "Home" : "Away").font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("UNC BASKETBALL RESULTS").navigationBarTitleDisplayMode(.inline).listStyle(PlainListStyle())
        }
        .task {
            await loadData()
        }
    }
    
    private func scoreColor(for result: Result) -> Color {
        if result.score.unc > result.score.opponent {
            return .green
        } else if result.score.unc < result.score.opponent {
            return .red
        } else {
            return .primary
        }
    }

    func loadData() async {
        guard let url = URL(string: "https://api.samuelshi.com/uncbasketball") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let decodedResults = try? JSONDecoder().decode([Result].self, from: data) {
                results = decodedResults
            } else {
                print("Failed to decode JSON")
            }
        } catch {
            print("Network error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
