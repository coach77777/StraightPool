import Foundation
import SwiftData


@Model
final class Player: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var phone: String?
    var email: String?
    var createdAt: Date

    init(id: UUID = UUID(), name: String, phone: String? = nil, email: String? = nil, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.createdAt = createdAt
    }
}

@Model
final class ScoreEvent: Identifiable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    /// 0 for player1, 1 for player2
    var playerIndex: Int
    /// +1 ball, -1 foul, -15 3-foul penalty, 0 markers (end turn / rack end)
    var delta: Int
    var label: String

    init(id: UUID = UUID(), timestamp: Date = .now, playerIndex: Int, delta: Int, label: String) {
        self.id = id
        self.timestamp = timestamp
        self.playerIndex = playerIndex
        self.delta = delta
        self.label = label
    }
}

@Model
final class Match: Identifiable {
    @Attribute(.unique) var id: UUID

    @Relationship var player1: Player
    @Relationship var player2: Player

    var targetScore: Int
    var score1: Int
    var score2: Int

    var fouls1: Int
    var fouls2: Int
    var consecutiveFouls1: Int
    var consecutiveFouls2: Int

    var currentRun1: Int
    var currentRun2: Int
    var highRun1: Int
    var highRun2: Int

    var activePlayerIndex: Int   // 0 or 1
    var isCompleted: Bool
    var winnerIndex: Int?

    @Relationship(deleteRule: .cascade) var events: [ScoreEvent]

    var createdAt: Date
    var note: String?

    init(
        id: UUID = UUID(),
        player1: Player,
        player2: Player,
        targetScore: Int = 100,
        createdAt: Date = .now
    ) {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.targetScore = targetScore
        self.score1 = 0
        self.score2 = 0
        self.fouls1 = 0
        self.fouls2 = 0
        self.consecutiveFouls1 = 0
        self.consecutiveFouls2 = 0
        self.currentRun1 = 0
        self.currentRun2 = 0
        self.highRun1 = 0
        self.highRun2 = 0
        self.activePlayerIndex = 0
        self.isCompleted = false
        self.winnerIndex = nil
        self.events = []
        self.createdAt = createdAt
    }
}
