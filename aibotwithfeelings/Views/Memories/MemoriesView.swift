import SwiftUI

struct MemoriesView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        NavigationStack {
            Group {
                if appModel.chatService.memories.isEmpty {
                    ContentUnavailableView(
                        "No memories yet",
                        systemImage: "brain.head.profile",
                        description: Text("As you chat, your companion will remember meaningful moments and feelings.")
                    )
                } else {
                    List {
                        ForEach(appModel.chatService.memories) { memory in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(memory.summary)
                                    .font(.body)

                                HStack {
                                    Text(memory.category.displayName)
                                    Spacer()
                                    Text("Weight \(Int(memory.emotionalWeight * 100))%")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteMemories)
                    }
                }
            }
            .navigationTitle("Memories")
        }
    }

    private func deleteMemories(at offsets: IndexSet) {
        for index in offsets {
            let memory = appModel.chatService.memories[index]
            appModel.chatService.deleteMemory(memory)
        }
    }
}

#Preview {
    MemoriesView(appModel: AppModel())
}
