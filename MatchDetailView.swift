import SwiftUI
import SwiftData
import Observation   // for @Bindable

struct MatchDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var match: Match

    private var sortedEvents: [ScoreEvent] {
        match.events.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            scoreStrip
            controls
            eventLog
        }
        .padding()
        .navigationTitle("Scorekeeper")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) { undo() } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(match.events.isEmpty)
            }
        }
    }

    // MARK: Header / Score

    private var header: some View {
        HStack {
            playerBadge(name: match.player1.name, isActive: match.activePlayerIndex == 0)
                .onTapGesture { match.activePlayerIndex = 0 }
            Spacer()
            targetBadge
            Spacer()
            playerBadge(name: match.player2.name, isActive: match.activePlayerIndex == 1)
                .onTapGesture { match.activePlayerIndex = 1 }
        }
    }

    private func playerBadge(name: String, isActive: Bool) -> some View {
        VStack {
            Text(name).font(.headline)
            Text(isActive ? "At table" : "Waiting")
                .font(.caption)
                .foregroundStyle(isActive ? .green : .secondary)
        }
        .padding(12)
        .background(.thinMaterial, in: .capsule)
        .overlay(
            Capsule().stroke(isActive ? .green : .clear, lineWidth: 2)
        )
    }

    private var targetBadge: some View {
        VStack {
            Text("Target").font(.caption)
            Text("\(match.targetScore)").font(.title2).monospacedDigit()
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }

    private var scoreStrip: some View {
        HStack(alignment: .bottom) {
            scoreColumn(name: match.player1.name, score: match.score1, fouls: match.fouls1, run: match.currentRun1, highRun: match.highRun1)
            Divider().frame(height: 90)
            scoreColumn(name: match.player2.name, score: match.score2, fouls: match.fouls2, run: match.currentRun2, highRun: match.highRun2)
        }
        .padding()
        .background(.quaternary.opacity(0.12), in: .rect(cornerRadius: 16))
    }

    private func scoreColumn(name: String, score: Int, fouls: Int, run: Int, highRun: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.subheadline).foregroundStyle(.secondary)
            Text("Score: \(score)").font(.title).monospacedDigit()
            HStack { Text("Run: \(run)"); Text("High: \(highRun)") }
                .font(.caption).foregroundStyle(.secondary)
            Text("Fouls: \(fouls)").font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Controls

    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                actionButton(title: "+1 Ball", systemImage: "plus.circle.fill") { addBall() }
                actionButton(title: "Foul −1", systemImage: "exclamationmark.triangle.fill") { addFoul() }
            }
            HStack {
                actionButton(title: "End Turn", systemImage: "arrow.right.circle") { endTurn() }
                actionButton(title: "Rack End", systemImage: "circle.grid.3x3") { rackEnd() }
            }
            if match.isCompleted {
                Text("Winner: \(match.winnerIndex == 0 ? match.player1.name : match.player2.name)")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else if match.score1 >= match.targetScore || match.score2 >= match.targetScore {
                Button {
                    finishMatch()
                } label: {
                    Label("Finish Match", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(.green.opacity(0.2), in: .rect(cornerRadius: 14))
                }
            }
        }
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack { Image(systemName: systemImage); Text(title) }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.thinMaterial, in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    // MARK: Event log

    private var eventLog: some View {
        List {
            Section("Event Log") {
                ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { _, e in
                    EventRow(
                        timeString: e.timestamp.formatted(date: .omitted, time: .shortened),
                        label: e.label,
                        playerName: (e.playerIndex == 0 ? match.player1.name : match.player2.name),
                        delta: e.delta
                    )
                }
            }
        }
        .frame(maxHeight: 260)
    }

    private struct EventRow: View {
        let timeString: String
        let label: String
        let playerName: String
        let delta: Int

        var body: some View {
            HStack {
                Text(timeString).font(.caption).foregroundStyle(.secondary)
                Text(label)
                Spacer()
                Text(playerName).foregroundStyle(.secondary)
                Text("\(delta >= 0 ? "+" : "")\(delta)")
                    .monospacedDigit()
                    .foregroundStyle(delta >= 0 ? Color.primary : Color.red)
            }
        }
    }

    // MARK: Logic

    private func addBall() {
        guard !match.isCompleted else { return }
        let i = match.activePlayerIndex
        if i == 0 {
            match.score1 += 1
            match.currentRun1 += 1
            match.highRun1 = max(match.highRun1, match.currentRun1)
            match.consecutiveFouls1 = 0
            log(delta: +1, label: "Ball", playerIndex: 0)
        } else {
            match.score2 += 1
            match.currentRun2 += 1
            match.highRun2 = max(match.highRun2, match.currentRun2)
            match.consecutiveFouls2 = 0
            log(delta: +1, label: "Ball", playerIndex: 1)
        }
        checkTarget(); save()
    }

    private func addFoul() {
        guard !match.isCompleted else { return }
        let i = match.activePlayerIndex
        if i == 0 {
            match.score1 -= 1
            match.fouls1 += 1
            match.consecutiveFouls1 += 1
            match.currentRun1 = 0
            log(delta: -1, label: "Foul", playerIndex: 0)
            if match.consecutiveFouls1 == 3 {
                match.score1 -= 15
                log(delta: -15, label: "3-Foul Penalty", playerIndex: 0)
                match.consecutiveFouls1 = 0
            }
        } else {
            match.score2 -= 1
            match.fouls2 += 1
            match.consecutiveFouls2 += 1
            match.currentRun2 = 0
            log(delta: -1, label: "Foul", playerIndex: 1)
            if match.consecutiveFouls2 == 3 {
                match.score2 -= 15
                log(delta: -15, label: "3-Foul Penalty", playerIndex: 1)
                match.consecutiveFouls2 = 0
            }
        }
        save()
    }

    private func rackEnd() {
        guard !match.isCompleted else { return }
        log(delta: 0, label: "Rack End", playerIndex: match.activePlayerIndex)
        save()
    }

    private func endTurn() {
        guard !match.isCompleted else { return }
        log(delta: 0, label: "End Turn", playerIndex: match.activePlayerIndex)
        if match.activePlayerIndex == 0 {
            match.currentRun1 = 0
            match.activePlayerIndex = 1
        } else {
            match.currentRun2 = 0
            match.activePlayerIndex = 0
        }
        save()
    }

    private func finishMatch() {
        match.isCompleted = true
        match.winnerIndex = match.score1 >= match.targetScore ? 0 : 1
        save()
    }

    private func undo() {
        guard let last = match.events.sorted(by: { $0.timestamp < $1.timestamp }).last else { return }
        revert(event: last)
        if let i = match.events.firstIndex(where: { $0.id == last.id }) {
            match.events.remove(at: i)
        }
        save()
    }

    private func revert(event: ScoreEvent) {
        let i = event.playerIndex
        switch event.label {
        case "Ball":
            if i == 0 { match.score1 -= 1; match.currentRun1 = max(0, match.currentRun1 - 1) }
            else       { match.score2 -= 1; match.currentRun2 = max(0, match.currentRun2 - 1) }
        case "Foul":
            if i == 0 { match.score1 += 1; match.fouls1 = max(0, match.fouls1 - 1); match.consecutiveFouls1 = max(0, match.consecutiveFouls1 - 1) }
            else       { match.score2 += 1; match.fouls2 = max(0, match.fouls2 - 1); match.consecutiveFouls2 = max(0, match.consecutiveFouls2 - 1) }
        case "3-Foul Penalty":
            if i == 0 { match.score1 += 15 } else { match.score2 += 15 }
        case "End Turn":
            match.activePlayerIndex = i
        default:
            break
        }
        if match.isCompleted { match.isCompleted = false; match.winnerIndex = nil }
    }

    private func log(delta: Int, label: String, playerIndex: Int) {
        match.events.append(ScoreEvent(playerIndex: playerIndex, delta: delta, label: label))
    }

    private func checkTarget() {
        if match.score1 >= match.targetScore || match.score2 >= match.targetScore { /* show finish button */ }
    }

    private func save() { try? context.save() }
}

