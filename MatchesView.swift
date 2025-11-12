import SwiftUI
import SwiftData

struct MatchesView: View {
    @Environment(\.modelContext) private var context

    // Load matches directly from SwiftData
    @Query(sort: \Match.createdAt, order: .reverse)
    private var matches: [Match]

    // For creating new matches
    @Query private var players: [Player]
    @State private var showingNewMatch = false

    var body: some View {
        NavigationStack {
            List {
                if matches.isEmpty {
                    ContentUnavailableView(
                        "No matches yet",
                        systemImage: "rectangle.on.rectangle.slash",
                        description: Text("Tap + to start a new match.")
                    )
                } else {
                    ForEach(matches) { m in
                        NavigationLink(destination: MatchDetailView(match: m)) {
                            VStack(alignment: .leading) {
                                Text("\(m.player1.name) vs \(m.player2.name)")
                                    .font(.headline)

                                Text(m.createdAt, format: .dateTime
                                        .month(.abbreviated)
                                        .day()
                                        .hour()
                                        .minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Matches")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewMatch = true
                    } label: {
                        Label("New Match", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewMatch) {
                // Whatever your new-match screen is called:
                NewMatchView(players: players)
            }
        }
    }
}
