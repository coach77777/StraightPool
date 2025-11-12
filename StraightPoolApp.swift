//
//  StraightPoolApp.swift
//  StraightPool
//
//  Created by Craig  on 11/12/25.
//

import SwiftUI
import SwiftData

@main
struct StraightPoolApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Player.self, Match.self, ScoreEvent.self])
    }
}
