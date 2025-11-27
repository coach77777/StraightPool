import SwiftUI
import SwiftData

@main
struct StraightPoolApp: App {
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: [Player.self, Match.self, ScoreEvent.self])
        }
    }
}
