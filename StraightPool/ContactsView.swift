import SwiftUI
import SwiftData

struct ContactsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.name) private var players: [Player]

    @State private var selectedIndex: Int? = nil

    // Currently selected player
    private var currentPlayer: Player? {
        guard !players.isEmpty else { return nil }

        let index = selectedIndex ?? 0
        guard players.indices.contains(index) else { return players.first }
        return players[index]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                // Dropdown-like field
                Menu {
                    ForEach(players.indices, id: \.self) { i in
                        Button {
                            selectedIndex = i
                        } label: {
                            HStack {
                                Text("#\(i + 1) \(players[i].name)")
                                if i == (selectedIndex ?? 0) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                label: {
                    HStack {
                        Text(selectedPlayerLabel)
                            .font(.headline)              // bigger text
                            .foregroundColor(.black)      // nice and dark on light gray

                        Spacer()

                        Image(systemName: "chevron.down")
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))    // super light gray background
                    )
                }
                .disabled(players.isEmpty)


                // Loaded count
                Text("Loaded: \(players.count) players")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Player details
                if let p = currentPlayer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player: \(displayLabel(for: p))")
                            .font(.headline)

                        if let phone = p.phone, !phone.isEmpty {
                            Text("Phone: \(phone)")
                        }

                        if let email = p.email, !email.isEmpty {
                            Text("Email: \(email)")
                        }
                    }

                    // Action buttons
                    HStack(spacing: 16) {
                        if let phone = p.phone, !phone.isEmpty {
                            Button("Call") { call(phone) }
                                .contactsButtonStyle(background: .green)

                            Button("Text") { text(phone) }
                                .contactsButtonStyle(background: .blue)
                        }

                        if let email = p.email, !email.isEmpty {
                            Button("Email") { emailPlayer(email) }
                                .contactsButtonStyle(background: .purple)
                        }
                    }
                    .padding(.top, 8)
                } else {
                    Text("No players available.")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Contacts")
            .onAppear {
                // Default selection
                if selectedIndex == nil && !players.isEmpty {
                    selectedIndex = 0
                }
                // If we have no players at all, try seeding from CSV
                if players.isEmpty {
                    importPlayersFromCSV()
                }
            }
        }
    }

    // MARK: - Helpers

    private var selectedPlayerLabel: String {
        guard let player = currentPlayer else {
            return "Select player"
        }
        return displayLabel(for: player)
    }

    /// "#index Name" label using the position in the sorted list
    private func displayLabel(for player: Player) -> String {
        if let idx = players.firstIndex(where: { $0.id == player.id }) {
            return "#\(idx + 1) \(player.name)"
        }
        return player.name
    }

    private func digits(from phone: String) -> String {
        phone.filter("0123456789".contains)
    }

    private func call(_ phone: String) {
        let number = digits(from: phone)
        guard let url = URL(string: "tel://\(number)") else { return }
        openURL(url)
    }

    private func text(_ phone: String) {
        let number = digits(from: phone)
        guard let url = URL(string: "sms:\(number)") else { return }
        openURL(url)
    }

    private func emailPlayer(_ email: String) {
        guard let url = URL(string: "mailto:\(email)") else { return }
        openURL(url)
    }

    // MARK: - CSV import

    /// Simple one-shot import from players.csv in the app bundle.
    private func importPlayersFromCSV() {
        // Adjust names if your file is in a subfolder or has a different name
        guard let url = Bundle.main.url(forResource: "players", withExtension: "csv") else {
            print(" players.csv not found in bundle")
            return
        }

        guard let content = try? String(contentsOf:url, encoding: .utf8) else {
            
            print(" Failed to read players.csv")
            return
        }

        let lines = content
            .split(whereSeparator: \.isNewline)
            .map { String($0) }

        guard lines.count > 1 else { return }

        // Assuming first line is header: id,name,phone,email,...
        for line in lines.dropFirst() {
            let cols = line.split(separator: ",").map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard cols.count >= 2 else { continue }

            let name = cols[1]
            let phone = cols.count > 2 ? cols[2] : nil
            let email = cols.count > 3 ? cols[3] : nil

            // Avoid duplicates if called twice
            if players.contains(where: { $0.name == name && $0.phone == phone }) {
                continue
            }

            let player = Player(
                name: name,
                phone: phone?.isEmpty == true ? nil : phone,
                email: email?.isEmpty == true ? nil : email
            )
            modelContext.insert(player)
        }

        do {
            try modelContext.save()
            print(" Imported players from CSV")
        } catch {
            print(" Failed to save imported players: \(error)")
        }
    }
}

// Reusable colorful button style
private extension View {
    func contactsButtonStyle(background: Color) -> some View {
        self
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(background)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
