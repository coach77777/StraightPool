import SwiftUI
import SwiftData

struct MatchesView: View {
    @Environment(\.modelContext) private var context

    // All matches, newest first (for history / admin later)
    @Query(sort: \Match.createdAt, order: .reverse)
    private var matches: [Match]

    // Players, so we can auto-fill Player A / B
    @Query(sort: \Player.name)
    private var players: [Player]

    @State private var showingSetupError = false
    @State private var setupErrorMessage = ""

    private var currentMatch: Match? {
        matches.first   // newest match
    }

    var body: some View {
        NavigationStack {
            Group {
                if let match = currentMatch {
                    // Just show the scorekeeper for the most recent match
                    MatchDetailView(match: match)
                } else {
                    // No matches yet → empty state
                    ContentUnavailableView(
                        "No matches yet",
                        systemImage: "rectangle.on.rectangle.slash",
                        description: Text("Tap + to start a new match.")
                    )
                }
            }
            .navigationTitle("Matches")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createQuickMatch()
                    } label: {
                        Label("New Match", systemImage: "plus.circle.fill")
                    }
                }
            }
            .alert("Unable to start match", isPresented: $showingSetupError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(setupErrorMessage)
            }
        }
    }

    // MARK: - Quick match creation

    private func createQuickMatch() {
        // Need at least two players in the DB
        guard players.count >= 2 else {
            setupErrorMessage = "Need at least two players.\nAsk your admin to import the player list."
            showingSetupError = true
            return
        }

        // For now: simple default choice
        let p1 = players[0]
        let p2 = players[1]

        let match = Match(
            player1: p1,
            player2: p2,
            targetScore: 125   // default target
        )

        // Optional: you can set a note like "Quick match" here
        // match.note = "Quick match"

        context.insert(match)

        do {
            try context.save()
        } catch {
            print("Failed to save match: \(error)")
            setupErrorMessage = "Could not save the new match."
            showingSetupError = true
        }
        // No manual navigation needed: @Query updates, `currentMatch`
        // becomes this new match, and the view redraws with it.
    }
}

