// OpeningBreakView.swift
import SwiftUI

struct OpeningBreakView: View {
    @Environment(\.dismiss) private var dismiss

    /// Game state that will be handed to the Scorekeeper
    @State var game: GameState

    /// Tracks which player is breaking + how many fouls so far
    @State var breakState: OpeningBreakState

    /// Called when opening-break logic is complete
    /// and we’re ready to jump into the Scorekeeper.
    var onStartScoring: (GameState) -> Void

    /// After a breaking foul, we show opponent choice:
    /// “Accept table” vs “Re-rack”
    @State private var showOpponentChoice = false

    private var breakerName: String {
        breakState.breakerIndex == 0 ? game.player1Name : game.player2Name
    }

    private var incomingName: String {
        breakState.breakerIndex == 0 ? game.player2Name : game.player1Name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Opening Break")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Breaker: \(breakerName)")
                .font(.headline)

            if !showOpponentChoice {
                // FIRST STEP – describe what happened on the break
                VStack(spacing: 16) {
                    primaryButton("Legal break") {
                        handleLegalBreak()
                    }

                    primaryButton("Legal break (called ball)") {
                        handleLegalCalledBall()
                    }

                    secondaryButton("Breaking foul  –2") {
                        handleBreakingFoul()
                    }
                }
            } else {
                // SECOND STEP – opponent decides after a breaking foul
                Text("Opponent’s choice after the breaking foul:")
                    .font(.headline)

                Text("Incoming player: \(incomingName)")
                    .font(.subheadline)

                HStack(spacing: 16) {
                    primaryButton("Accept table (start)") {
                        acceptTable()
                    }

                    secondaryButton("Re-rack (same breaker)") {
                        rerackAfterFoul()
                    }
                }
            }

            Spacer()

            Button("Back") {
                dismiss()
            }
            .padding(.top, 16)
        }
        .padding()
    }

    // MARK: - Actions

    /// Legal break, no ball made → incoming player starts scorekeeper.
    private func handleLegalBreak() {
        game.applyOpeningBreakResult(.legalBreak,
                                     breakerIndex: breakState.breakerIndex)
        breakState.reset()
        finishAndStartScoring()
    }

    /// Called ball on the break → breaker keeps shooting.
    private func handleLegalCalledBall() {
        game.applyOpeningBreakResult(.legalCalledBall,
                                     breakerIndex: breakState.breakerIndex)
        breakState.reset()
        finishAndStartScoring()
    }

    /// Breaking foul: −2, and possibly −15 on the 3rd foul.
    private func handleBreakingFoul() {
        let result = breakState.recordFoul()
        game.applyOpeningBreakResult(result,
                                     breakerIndex: breakState.breakerIndex)

        switch result {
        case .foulMinus2:
            // Show opponent choice: Accept vs Re-rack.
            showOpponentChoice = true

        case .thirdFoulMinus15:
            // 3rd foul: automatic −15 and incoming player starts.
            finishAndStartScoring()

        default:
            break
        }
    }

    /// Opponent accepts the table as is and starts shooting.
    private func acceptTable() {
        // At this point `applyOpeningBreakResult` has already:
        //  - given -2 to the breaker
        //  - switched activePlayerIndex to the incoming player
        finishAndStartScoring()
    }

    /// Opponent demands a re-rack; same breaker tries again.
    private func rerackAfterFoul() {
        // We keep the penalty already applied to the breaker’s score.
        showOpponentChoice = false
        // BreakerIndex stays the same; we’re just waiting for the next result.
    }

    /// Common exit point: send final GameState to caller and dismiss.
    private func finishAndStartScoring() {
        onStartScoring(game)
        dismiss()
    }

    // MARK: - Button Helpers

    private func primaryButton(_ title: String,
                               action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.purple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private func secondaryButton(_ title: String,
                                 action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(.purple)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.purple, lineWidth: 1)
                )
        }
    }
}
