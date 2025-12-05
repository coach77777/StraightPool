import SwiftUI
import SwiftData
import Observation

struct MatchDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var match: Match

    var body: some View {
        VStack(spacing: 16) {
            Text("Straight Pool Scoring")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            metaHeader             // week / innings / rack

           

            scoreStrip             // two big player cards

            controls               // 5 buttons: +1, Safety, End Turn, Foul, Deliberate Foul

            eventLog               // placeholder for future innings log
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) { undo() } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(match.events.isEmpty)
            }
        }
    }

    // MARK: - Meta header (week / innings / rack)

    private var metaHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !match.weekLabel.isEmpty {
                Text("Week: \(match.weekLabel)")
                    .font(.subheadline)
            }

            Text("Innings: \(match.innings)")
                .font(.subheadline)

            Text(rackHeaderLine)
                .font(.subheadline)

            Text(rackDetailLine)
                .font(.subheadline.weight(.semibold))   // same size/weight as above
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Header (target only – players are styled in cards)

    private var header: some View {
        HStack {
            Spacer()
            targetBadge
            Spacer()
        }
    }

    private var targetBadge: some View {
        VStack {
            Text("Target").font(.caption)
            Text("\(match.targetScore)")
                .font(.title2)
                .monospacedDigit()
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Score cards

    private var scoreStrip: some View {
        HStack(spacing: 12) {
            playerScoreCard(
                name: match.player1.name,
                score: match.score1,
                fouls: match.fouls1,
                foulsInRow: match.consecutiveFouls1,
                run: match.currentRun1,
                highRun: match.highRun1,
                isActive: match.activePlayerIndex == 0,
                playerIndex: 0
            )

            playerScoreCard(
                name: match.player2.name,
                score: match.score2,
                fouls: match.fouls2,
                foulsInRow: match.consecutiveFouls2,
                run: match.currentRun2,
                highRun: match.highRun2,
                isActive: match.activePlayerIndex == 1,
                playerIndex: 1
            )
        }
    }

    /// A single player score card – Android-style:
    /// - Green border when at table
    /// - Orange border + “2 Foul Warning” on 2+ fouls in a row
    /// - Tap card to set active player
    private func playerScoreCard(
        name: String,
        score: Int,
        fouls: Int,
        foulsInRow: Int,
        run: Int,
        highRun: Int,
        isActive: Bool,
        playerIndex: Int
    ) -> some View {
        let isOnTwoFouls = foulsInRow >= 2

        let borderColor: Color =
            isOnTwoFouls ? .orange :
            (isActive ? .green : .clear)

        let scoreColor: Color =
            isActive ? .green : .primary

        return VStack(alignment: .leading, spacing: 6) {
            // Name
            Text(name)
                .font(.headline)

            // Score line
            Text("Score: \(score)")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(scoreColor)

            // Run / High run
            HStack(spacing: 12) {
                Text("Run: \(run)")
                Text("High: \(highRun)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // Total fouls this match
            Text("Fouls: \(fouls)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Status line: At table / Waiting / 2 Foul Warning
            if isOnTwoFouls {
                Text("2 Foul Warning")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            } else {
                Text(isActive ? "At table" : "Waiting")
                    .font(.caption)
                    .foregroundStyle(isActive ? .green : .secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: isOnTwoFouls ? 3 : (isActive ? 2 : 0))
        )
        .onTapGesture {
            match.activePlayerIndex = playerIndex
        }
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 12) {

            // Row 1 – same idea as Android
            HStack {
                actionButton(title: "Pocket Ball +1", systemImage: "plus.circle.fill") {
                    addBall()
                }

                actionButton(title: "Safety", systemImage: "shield.lefthalf.filled") {
                    safety()
                }

                actionButton(title: "End Turn", systemImage: "arrow.turn.down.right") {
                    endTurn()
                }
            }

            // Row 2 – foul row
            HStack {
                actionButton(title: "Foul −1", systemImage: "exclamationmark.triangle.fill") {
                    addFoul(isDeliberate: false)
                }

                actionButton(title: "Deliberate Foul −16", systemImage: "flame.fill") {
                    addFoul(isDeliberate: true)
                }
            }

            if match.isCompleted {
                let winnerName = (match.winnerIndex == 0 ? match.player1.name : match.player2.name)

                Text("Winner: \(winnerName)")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)   // winner name in white
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)   // solid dark green
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            }

        }
    

    private func actionButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Event log (placeholder for now)

    private var eventLog: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Log")
                .font(.headline)

            Text("Detailed shot-by-shot history will be added in a later version.")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .padding(.top, 12)
    }

    // MARK: - Actions / Logic

    /// Add a potted ball for the active player.
    /// Does NOT change shooter or inning.
    private func addBall() {
        guard !match.isCompleted else { return }

        let i = match.activePlayerIndex

        if i == 0 {
            match.score1 += 1
            match.currentRun1 += 1
            match.highRun1 = max(match.highRun1, match.currentRun1)
            match.consecutiveFouls1 = 0
        } else {
            match.score2 += 1
            match.currentRun2 += 1
            match.highRun2 = max(match.highRun2, match.currentRun2)
            match.consecutiveFouls2 = 0
        }

        log(delta: +1, label: "Ball", playerIndex: i)
        checkTarget()
        save()
    }

    /// Safety: no score change, resets run, changes player,
    /// and counts as a completed turn (like Android).
    private func safety() {
        guard !match.isCompleted else { return }

        let i = match.activePlayerIndex

        if i == 0 {
            match.currentRun1 = 0
        } else {
            match.currentRun2 = 0
        }

        log(delta: 0, label: "Safety", playerIndex: i)

        advanceTurnAndInning()
        save()
    }

    /// Foul button:
    ///  - Normal foul: −1 each time, increments consecutive fouls.
    ///    On 3rd consecutive foul, adds an extra −15 (separate event) and resets streak.
    ///  - Deliberate foul: immediately does −1 plus −15 extra (total −16) and resets streak.
    /// In all cases, turn passes to the opponent and inning logic advances.
    private func addFoul(isDeliberate: Bool) {
        guard !match.isCompleted else { return }

        let i = match.activePlayerIndex

        if i == 0 {
            // Player 1 foul
            match.fouls1 += 1
            match.currentRun1 = 0

            if isDeliberate {
                // Deliberate foul = -1 + -15 = -16, streak reset
                match.score1 -= 1
                log(delta: -1, label: "Foul", playerIndex: 0)

                match.score1 -= 15
                log(delta: -15, label: "3-Foul Penalty", playerIndex: 0)

                match.consecutiveFouls1 = 0
            } else {
                // Normal foul sequence: -1, -1, then -15
                if match.consecutiveFouls1 == 2 {
                    // This is the THIRD consecutive foul
                    match.score1 -= 15
                    log(delta: -15, label: "3-Foul Penalty", playerIndex: 0)
                    match.consecutiveFouls1 = 0
                } else {
                    // First or second foul in the streak
                    match.score1 -= 1
                    log(delta: -1, label: "Foul", playerIndex: 0)
                    match.consecutiveFouls1 += 1
                }
            }

        } else {
            // Player 2 foul
            match.fouls2 += 1
            match.currentRun2 = 0

            if isDeliberate {
                match.score2 -= 1
                log(delta: -1, label: "Foul", playerIndex: 1)

                match.score2 -= 15
                log(delta: -15, label: "3-Foul Penalty", playerIndex: 1)

                match.consecutiveFouls2 = 0
            } else {
                if match.consecutiveFouls2 == 2 {
                    // THIRD consecutive foul for player 2
                    match.score2 -= 15
                    log(delta: -15, label: "3-Foul Penalty", playerIndex: 1)
                    match.consecutiveFouls2 = 0
                } else {
                    match.score2 -= 1
                    log(delta: -1, label: "Foul", playerIndex: 1)
                    match.consecutiveFouls2 += 1
                }
            }
        }

        // Same as before: after ANY foul, turn passes & innings update
        advanceTurnAndInning()
        save()
    }


    /// Player intentionally ends turn: no score, no foul,
    /// resets their run and passes table to opponent.
    private func endTurn() {
        guard !match.isCompleted else { return }

        let i = match.activePlayerIndex

        if i == 0 {
            match.currentRun1 = 0
        } else {
            match.currentRun2 = 0
        }

        log(delta: 0, label: "End Turn", playerIndex: i)

        advanceTurnAndInning()
        save()
    }

    /// Shared helper: toggles shooter and advances half-innings.
    /// Called by Safety, Foul, End Turn.
    private func advanceTurnAndInning() {
        // Toggle active player
        match.activePlayerIndex = (match.activePlayerIndex == 0) ? 1 : 0

        // Half-inning bookkeeping:
        // 0 → first shooter in this inning, 1 → second shooter.
        if match.turnsInCurrentInning == 0 {
            match.turnsInCurrentInning = 1
        } else {
            match.turnsInCurrentInning = 0
            match.innings += 1
        }
    }

    private func finishMatch() {
        match.isCompleted = true
        match.winnerIndex = match.score1 >= match.targetScore ? 0 : 1
        save()
    }

    private func undo() {
        guard let last = match.events.sorted(by: { $0.timestamp < $1.timestamp }).last else { return }
        revert(event: last)
        if let idx = match.events.firstIndex(where: { $0.id == last.id }) {
            match.events.remove(at: idx)
        }
        save()
    }

    private func revert(event: ScoreEvent) {
        let i = event.playerIndex
        switch event.label {
        case "Ball":
            if i == 0 {
                match.score1 -= 1
                match.currentRun1 = max(0, match.currentRun1 - 1)
            } else {
                match.score2 -= 1
                match.currentRun2 = max(0, match.currentRun2 - 1)
            }

        case "Foul":
            if i == 0 {
                match.score1 += 1
                match.fouls1 = max(0, match.fouls1 - 1)
                match.consecutiveFouls1 = max(0, match.consecutiveFouls1 - 1)
            } else {
                match.score2 += 1
                match.fouls2 = max(0, match.fouls2 - 1)
                match.consecutiveFouls2 = max(0, match.consecutiveFouls2 - 1)
            }

        case "3-Foul Penalty":
            if i == 0 {
                match.score1 += 15
            } else {
                match.score2 += 15
            }

        case "End Turn":
            // Flip back to the shooter who just ended turn.
            match.activePlayerIndex = i

        case "Safety":
            // Also flip back for safety if needed.
            match.activePlayerIndex = i

        default:
            break
        }

        if match.isCompleted {
            match.isCompleted = false
            match.winnerIndex = nil
        }
    }

    private func log(delta: Int, label: String, playerIndex: Int) {
        let e = ScoreEvent(playerIndex: playerIndex, delta: delta, label: label)
        match.events.append(e)
    }

private func checkTarget() {
    // Only mark it once
    guard !match.isCompleted else { return }

    if match.score1 >= match.targetScore || match.score2 >= match.targetScore {
        match.isCompleted = true
        match.winnerIndex = match.score1 >= match.targetScore ? 0 : 1
        save()
    }
}

    private func save() {
        try? context.save()
    }

    // MARK: - Rack logic (14.1 continuous)

    /// Only counts *pocketed balls* (positive deltas), not fouls or safeties.
    private var totalPocketedBalls: Int {
        match.events.reduce(0) { partial, e in
            partial + max(e.delta, 0)
        }
    }

    /// Rack number following your rule:
    /// - Rack 1: start of match (15-ball rack).
    /// - After that, rack increments on multiples of 14.
    private var currentRackNumber: Int {
        let total = totalPocketedBalls
        if total <= 0 { return 1 }
        return 1 + total / 14
    }

    /// Balls made in the *current* rack.
    private var ballsMadeThisRack: Int {
        let total = totalPocketedBalls

        if currentRackNumber == 1 {
            // First rack is a true 15-ball rack.
            return min(total, 15)
        } else {
            // Subtract the first 14 balls that move you past rack 1,
            // then work in 14-ball chunks for later racks.
            let extra = max(0, total - 14)
            return extra % 14
        }
    }

    /// Capacity of the current rack.
    /// - Rack 1: 15 balls.
    /// - Later racks: 14 balls (plus 1 break ball on the table).
    private var ballsCapacityThisRack: Int {
        currentRackNumber == 1 ? 15 : 14
    }

    /// Balls remaining in this rack (capacity minus balls made).
    private var ballsRemainingThisRack: Int {
        max(0, ballsCapacityThisRack - ballsMadeThisRack)
    }

    /// First rack line, e.g.
    /// - "Rack: 1 · 15 balls in rack"
    /// - "Rack: 2 · 14 balls in rack + 1 break ball"
    private var rackHeaderLine: String {
        if currentRackNumber == 1 {
            return "Rack: 1 · 15 balls in rack"
        } else {
            return "Rack: \(currentRackNumber) · 14 balls in rack + 1 break ball"
        }
    }

    /// Second rack line, e.g. "5 made this rack, 9 remaining"
    private var rackDetailLine: String {
        "\(ballsMadeThisRack) made this rack, \(ballsRemainingThisRack) remaining"
    }
}
