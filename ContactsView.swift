
import SwiftUI
import SwiftData

struct ContactsView: View {
    @Environment(\.openURL) private var openURL
    @Query(sort: \Player.name) private var players: [Player]

    // Index of the selected player in the players array
    @State private var selectedIndex: Int = 0

    /// Currently selected player (or nil if there are no players)
    private var currentPlayer: Player? {
        guard !players.isEmpty else { return nil }
        // Clamp in case count changes
        let clamped = min(max(selectedIndex, 0), players.count - 1)
        return players[clamped]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                // If no players at all, show message and bail out
                if players.isEmpty {
                    Text("No players imported.\nAsk your league admin to import the player list.")
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {

                    // MARK: - Select player "dropdown" field
                    Menu {
                        ForEach(players.indices, id: \.self) { i in
                            Button {
                                selectedIndex = i
                            } label: {
                                HStack {
                                    Text("#\(i + 1) \(players[i].name)")
                                    if i == selectedIndex {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedPlayerLabel)
                                .foregroundColor(.black)   // darker text
                                .fontWeight(.medium)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)   // darker chevron
                        }
                        .padding(.horizontal)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))   // light gray background
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    }



                    // MARK: - Loaded count
                    Text("Loaded: \(players.count) players")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // MARK: - Player details + buttons
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
                    }
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Contacts")
            .onAppear {
                // Make sure selectedIndex is valid when view appears
                if !players.isEmpty && !players.indices.contains(selectedIndex) {
                    selectedIndex = 0
                }
            }
        }
    }

    // MARK: - Helpers

    /// Text shown inside the dropdown
    private var selectedPlayerLabel: String {
        guard let player = currentPlayer else {
            return "Select player"
        }
        return displayLabel(for: player)
    }

    /// "#index Name" label using position in sorted list
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
}

// MARK: - Reusable colorful button style

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
