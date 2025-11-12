import SwiftUI
import SwiftData

struct NewMatchView: View {
    let players: [Player]          // <- this part is important

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("New Match")
                    .font(.title)
                    .bold()

                Text("Placeholder screen – we’ll wire this up next.")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("New Match")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
