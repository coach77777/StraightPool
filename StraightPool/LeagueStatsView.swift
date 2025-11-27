import SwiftUI
import SwiftData

struct LeagueStatsView: View {
    @Query private var matches: [Match]

    var body: some View {
        NavigationStack {
            List {
                Section("Totals") {
                    Text("Matches: \(matches.count)")
                    Text("Completed: \(matches.filter { $0.isCompleted }.count)")
                }
                Section("High Runs") {
                    ForEach(matches) { m in
                        VStack(alignment: .leading) {
                            Text("\(m.player1.name) vs \(m.player2.name)")
                            Text("High: \(m.highRun1) / \(m.highRun2)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("League Stats")
        }
    }
}

