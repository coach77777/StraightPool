// GameState.swift
import Foundation

/// Simple game state used by the scorekeeper & opening-break flow.
struct GameState {
    // Names
    var player1Name: String
    var player2Name: String

    // Scores
    var score1: Int
    var score2: Int

    // Total fouls (or you can treat these as “foul points”, your call)
    var fouls1: Int
    var fouls2: Int

    // For tracking 3-foul rule during the match (not just the break)
    var consecutiveFouls1: Int
    var consecutiveFouls2: Int

    /// Who is currently at the table: 0 = player1, 1 = player2
    var activePlayerIndex: Int

    // MARK: - Opening break resolution

    /// Apply the result of the opening break to the scores
    /// - Parameters:
    ///   - result: outcome of the break
    ///   - breakerIndex: 0 if player1 broke, 1 if player2 broke
    mutating func applyOpeningBreakResult(
        _ result: OpeningBreakResult,
        breakerIndex: Int
    ) {
        switch result {
        case .legalBreak:
            // Legal break, no ball: incoming player shoots
            activePlayerIndex = breakerIndex == 0 ? 1 : 0

        case .legalCalledBall:
            // Breaker made the called ball: breaker keeps shooting
            activePlayerIndex = breakerIndex

        case .foulMinus2:
            // -2 to the breaker, incoming player gets the table
            if breakerIndex == 0 {
                score1 -= 2
                fouls1 += 1
                consecutiveFouls1 += 1
                consecutiveFouls2 = 0
            } else {
                score2 -= 2
                fouls2 += 1
                consecutiveFouls2 += 1
                consecutiveFouls1 = 0
            }
            activePlayerIndex = breakerIndex == 0 ? 1 : 0

        case .thirdFoulMinus15:
            // Third foul on the break: -15
            if breakerIndex == 0 {
                score1 -= 15
                fouls1 += 1
                consecutiveFouls1 = 3
                consecutiveFouls2 = 0
            } else {
                score2 -= 15
                fouls2 += 1
                consecutiveFouls2 = 3
                consecutiveFouls1 = 0
            }
            activePlayerIndex = breakerIndex == 0 ? 1 : 0
        }
    }
}
