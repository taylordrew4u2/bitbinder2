//
//  SetListsView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct SetListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SetList.updatedAt, order: .reverse) private var setLists: [SetList]
    
    @State private var searchText = ""
    
    private var filteredSetLists: [SetList] {
        if searchText.isEmpty {
            return setLists
        }
        return setLists.filter { setList in
            setList.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if setLists.isEmpty {
                EmptyStateView(
                    title: "No Set Lists Yet",
                    message: "Create your first set list to organize your jokes",
                    icon: "music.note.list"
                )
            } else {
                List {
                    ForEach(filteredSetLists) { setList in
                        NavigationLink(destination: SetListDetailView(setList: setList)) {
                            SetListRowView(setList: setList)
                        }
                    }
                    .onDelete(perform: deleteSetLists)
                }
                .searchable(text: $searchText, prompt: "Search set lists...")
            }
        }
        .navigationTitle("Set Lists")
    }
    
    private func deleteSetLists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredSetLists[index])
            }
        }
    }
}

struct SetListRowView: View {
    let setList: SetList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(setList.name)
                .font(.headline)
            
            HStack {
                Label("\(setList.jokeOrder.count) jokes", systemImage: "text.bubble")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let lastPerformed = setList.lastPerformedAt {
                    Text("• Last performed \(lastPerformed.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = try! ModelContainer(for: [Joke.self, SetList.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let joke1 = Joke(title: "Opening", body: "Great opener")
    let joke2 = Joke(title: "Middle", body: "Solid middle")
    container.mainContext.insert(joke1)
    container.mainContext.insert(joke2)
    
    let setList = SetList(name: "Friday Night Set", jokeOrder: [joke1.id, joke2.id])
    container.mainContext.insert(setList)
    
    return NavigationStack {
        SetListsView()
    }
    .modelContainer(container)
}
