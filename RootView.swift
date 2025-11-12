import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MatchesView()
                .tabItem { Label("Matches", systemImage: "list.bullet.rectangle") }

            PlayersView()
                .tabItem { Label("Players", systemImage: "person.2") }

            LeagueStatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.xaxis") }
        }
    }
}

