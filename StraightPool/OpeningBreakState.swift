import Foundation

/// Tracks repeated fouls during the opening break.
struct OpeningBreakState {
    /// 0 = player 1 breaks, 1 = player 2 breaks.
    var breakerIndex: Int = 0
    /// Number of fouls committed by the breaker during the opening break.
    var foulCount: Int = 0

    /// Register a new foul and return what penalty applies.
    mutating func recordFoul() -> OpeningBreakResult {
        foulCount += 1
        if foulCount >= 3 {
            return .thirdFoulMinus15
        } else {
            return .foulMinus2
        }
    }

    /// Reset foul tracking (e.g. after a completely new match).
    mutating func reset() {
        foulCount = 0
    }
}

/// All possible results from the opening break.
enum OpeningBreakResult {
    /// Legal break, no ball made.
    case legalBreak
    /// Legal break with a called ball made.
    case legalCalledBall
    /// Breaking foul, -2 points to the breaker.
    case foulMinus2
    /// Third foul on the break, -15 points to the breaker.
    case thirdFoulMinus15
}
