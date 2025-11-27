
import SwiftUI
import SwiftData

struct NewMatchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Players from SwiftData, sorted by name.
    @Query(sort: \Player.name) private var players: [Player]

    // Simple weeks list for now – later we can load from weeks.csv
    private let weeks: [String] = [
        "Wk-1 – 3-Sep",
        "Wk-2 – 10-Sep",
        "Wk-3 – 17-Sep",
        "Wk-4 – 24-Sep"
        // …add more as needed
    ]

    @State private var selectedWeekIndex: Int = 0
    @State private var playerAIndex: Int = 0
    @State private var playerBIndex: Int = 1
    @State private var targetScoreText: String = "125"

    // Opening-break / scoring wiring
    @State private var showOpeningBreak = false
    @State private var openingGameState: GameState? = nil
    @State private var openingBreakState = OpeningBreakState()
    @State private var pendingMatch: Match? = nil

    /// Called back to StartView when a new Match is ready
    /// so StartView can present MatchDetailView (scorekeeper).
    let onMatchCreated: (Match) -> Void

    // MARK: - Derived values

    private var targetScore: Int? {
        Int(targetScoreText)
    }

    private var canStartMatch: Bool {
        guard players.count >= 2 else { return false }
        guard playerAIndex != playerBIndex else { return false }
        guard let t = targetScore, t > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                // Week / Date
                Section("Week / Date") {
                    Picker("Week", selection: $selectedWeekIndex) {
                        ForEach(weeks.indices, id: \.self) { i in
                            Text(weeks[i]).tag(i)
                        }
                    }
                }

                // Player A / Player B
                Section {
                    if players.count < 2 {
                        Text("Need at least two players.\nAsk your admin to import the player list.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Player A", selection: $playerAIndex) {
                            ForEach(players.indices, id: \.self) { i in
                                Text(players[i].name).tag(i)
                            }
                        }

                        Picker("Player B", selection: $playerBIndex) {
                            ForEach(players.indices, id: \.self) { i in
                                Text(players[i].name).tag(i)
                            }
                        }
                    }
                } header: {
                    Text("Players")
                }

                // Target score
                Section("Target score") {
                    TextField("Target score", text: $targetScoreText)
                        .keyboardType(.numberPad)
                }

                // Opening Break button
                Section {
                    Button {
                        startMatchAndShowOpeningBreak()
                    } label: {
                        Text("Opening Break")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(Color.purple)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                            )
                    }
                    .disabled(!canStartMatch)
                    .opacity(canStartMatch ? 1.0 : 0.4)
                }
            }
            .navigationTitle("Match Setup")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Opening Break sheet
            .sheet(isPresented: $showOpeningBreak) {
                if let game = openingGameState,
                   let match = pendingMatch {
                    OpeningBreakView(
                        game: game,
                        breakState: openingBreakState
                    ) { finalGame in
                        // 1) Apply GameState → Match
                        applyOpeningResult(finalGame, to: match)

                        // 2) Save
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save match after opening break: \(error)")
                        }

                        // 3) Tell StartView which match to open in Scorekeeper
                        onMatchCreated(match)

                        // 4) Dismiss this Match Setup sheet
                        dismiss()
                    }
                } else {
                    Text("Unable to start opening break.")
                        .padding()
                }
            }
        }
    }

    // MARK: - Actions

    private func startMatchAndShowOpeningBreak() {
        guard canStartMatch,
              let target = targetScore,
              players.indices.contains(playerAIndex),
              players.indices.contains(playerBIndex) else { return }

        let p1 = players[playerAIndex]
        let p2 = players[playerBIndex]

        // 1) Create & save Match in SwiftData
        let match = Match(
            player1: p1,
            player2: p2,
            targetScore: target,
            weekLabel: selectedWeekLabel // <-- whatever your Week / Date picker exposes        )
        match.note = weeks[selectedWeekIndex]

        modelContext.insert(match)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save match: \(error)")
        }

        pendingMatch = match

        // 2) Build initial GameState for the opening break
        openingBreakState = OpeningBreakState(breakerIndex: 0, foulCount: 0)

        openingGameState = GameState(
            player1Name: p1.name,
            player2Name: p2.name,
            score1: 0,
            score2: 0,
            fouls1: 0,
            fouls2: 0,
            consecutiveFouls1: 0,
            consecutiveFouls2: 0,
            activePlayerIndex: openingBreakState.breakerIndex
        )

        // 3) Show Opening Break screen
        showOpeningBreak = true
    }

    /// Copy the final GameState from the opening break into the Match model.
    private func applyOpeningResult(_ finalGame: GameState, to match: Match) {
        // Normal case: names line up with player1/player2
        if finalGame.player1Name == match.player1.name,
           finalGame.player2Name == match.player2.name {
            match.score1 = finalGame.score1
            match.score2 = finalGame.score2
            match.fouls1 = finalGame.fouls1
            match.fouls2 = finalGame.fouls2
            match.consecutiveFouls1 = finalGame.consecutiveFouls1
            match.consecutiveFouls2 = finalGame.consecutiveFouls2
            match.activePlayerIndex = finalGame.activePlayerIndex
        } else {
            // Fallback (if names were swapped for some reason)
            match.score1 = finalGame.score2
            match.score2 = finalGame.score1
            match.fouls1 = finalGame.fouls2
            match.fouls2 = finalGame.fouls1
            match.consecutiveFouls1 = finalGame.consecutiveFouls2
            match.consecutiveFouls2 = finalGame.consecutiveFouls1
            match.activePlayerIndex = finalGame.activePlayerIndex == 0 ? 1 : 0
        }
    }
}
