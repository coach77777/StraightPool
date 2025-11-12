import SwiftUI
import SwiftData

struct PlayersView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Player.createdAt, order: .reverse) private var players: [Player]
    @State private var newName: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Add Player") {
                    HStack {
                        TextField("Name", text: $newName)
                        Button("Add") { addPlayer() }
                            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                Section("All Players") {
                    ForEach(players) { p in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(p.name).font(.headline)
                                if let email = p.email {
                                    Text(email).foregroundStyle(.secondary).lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Players")
            .toolbar { EditButton() }
        }
    }

    private func addPlayer() {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        context.insert(Player(name: trimmed))
        newName = ""
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(players[i]) }
        try? context.save()
    }
}

