//// OpeningBreakLogic.swift
//import Foundation
//
//extension GameState {
//    /// Apply the result of the opening break to the current game state.
//    mutating func applyOpeningBreakResult(_ result: OpeningBreakResult,
//                                          breakerIndex: Int) {
//        switch result {
//        case .legalBreak:
//            // Incoming player shoots first
//            currentShooter = breakerIndex == 0 ? 1 : 0
//
//        case .legalCalledBall:
//            // Breaker keeps shooting
//            currentShooter = breakerIndex
//
//        case .foulMinus2:
//            if breakerIndex == 0 { player1Score -= 2 }
//            else { player2Score -= 2 }
//            // Incoming player chooses Accept Table / Re-rack in UI
//
//        case .thirdFoulMinus15:
//            if breakerIndex == 0 { player1Score -= 15 }
//            else { player2Score -= 15 }
//            // After third foul, incoming player shoots
//            currentShooter = breakerIndex == 0 ? 1 : 0
//        }
//    }
//}
