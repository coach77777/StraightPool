import SwiftUI
import SwiftData

struct PlayersView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Player.name) private var players: [Player]
    @State private var selectedIndex: Int = 0

    private var currentPlayer: Player? {
        guard !players.isEmpty else { return nil }
        return players[min(selectedIndex, players.count - 1)]
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                if players.isEmpty {
                    Text("No players loaded.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                } else {

                    // DROPDOWN
                    Picker("Select player", selection: $selectedIndex) {
                        ForEach(players.indices, id: \.self) { i in
                            Text("#\(i + 1) \(players[i].name)")
                                .font(.system(size: 20, weight: .bold))
                                .tag(i)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("Loaded: \(players.count) players")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let p = currentPlayer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player: #\(selectedIndex + 1) \(p.name)")
                                .font(.headline)

                            if let phone = p.phone, !phone.isEmpty {
                                Text("Phone: \(phone)")
                            }

                            if let email = p.email, !email.isEmpty {
                                Text("Email: \(email)")
                            }
                        }
                        .padding(.top, 8)

                        HStack(spacing: 16) {
                            if let phone = p.phone, !phone.isEmpty {
                                Button("Call") { call(phone) }
                                    .buttonStyle(.borderedProminent)

                                Button("Text") { text(phone) }
                                    .buttonStyle(.bordered)
                            }

                            if let email = p.email, !email.isEmpty {
                                Button("Email") { emailPlayer(email) }
                                    .buttonStyle(.bordered)
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Players")
        }
    }

    // MARK: - Actions

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
