import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            // Matches tab
            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "list.bullet.rectangle")
                }

            // Players / Contacts tab
            PlayersView()
                .tabItem {
                    Label("Players", systemImage: "person.2")
                }

            // Stats tab
            LeagueStatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    // Preview with an in-memory SwiftData container
    RootView()
        .modelContainer(for: [Player.self, Match.self, ScoreEvent.self], inMemory: true)
}
