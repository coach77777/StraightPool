import SwiftUI
import SwiftData

struct StartView: View {

    enum ActiveSheet: Identifiable {
        case matchSetup
        case contacts

        var id: Int {
            switch self {
            case .matchSetup: return 1
            case .contacts: return 2
            }
        }
    }

    @State private var activeSheet: ActiveSheet? = nil
    @State private var activeMatch: Match? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240)

                startScreenPrimaryButton(title: "Start Match") {
                    activeSheet = .matchSetup
                }

                startScreenSecondaryButton(title: "Contacts") {
                    activeSheet = .contacts
                }

                Spacer()
            }
            .padding()
        }

        // SHEET: Match Setup
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .matchSetup:
                NavigationStack {
                    NewMatchView { newMatch in
                        // Callback from NewMatchView → go to scorekeeper
                        activeMatch = newMatch
                        activeSheet = nil
                    }
                }

            case .contacts:
                NavigationStack {
                    ContactsView()
                }
            }
        }

        //  SHEET: Scorekeeper (MatchDetailView)
        .sheet(item: $activeMatch) { match in
            NavigationStack {
                MatchDetailView(match: match)
            }
        }
    }

    // MARK: - Button styles

    private func startScreenPrimaryButton(title: String,
                                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func startScreenSecondaryButton(title: String,
                                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
