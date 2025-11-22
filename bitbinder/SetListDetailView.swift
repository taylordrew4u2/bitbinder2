//
//  SetListDetailView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct SetListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allJokes: [Joke]
    
    let setList: SetList
    
    @State private var showingDeleteAlert = false
    @State private var showingRecordView = false
    
    private var jokes: [Joke] {
        setList.jokeOrder.compactMap { jokeId in
            allJokes.first(where: { $0.id == jokeId })
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("\(setList.jokeOrder.count) jokes", systemImage: "text.bubble")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if let lastPerformed = setList.lastPerformedAt {
                            Text("Last performed \(lastPerformed.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        showingRecordView = true
                    } label: {
                        Label("Record This Set", systemImage: "record.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                if jokes.isEmpty {
                    Text("No jokes in this set")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(Array(jokes.enumerated()), id: \.element.id) { index, joke in
                        HStack {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(joke.title)
                                    .font(.body)
                                
                                if !joke.body.isEmpty {
                                    Text(joke.body)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            } header: {
                Text("Joke Order")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    InfoRow(label: "Created", value: setList.createdAt.formatted(date: .abbreviated, time: .shortened))
                    InfoRow(label: "Last Modified", value: setList.updatedAt.formatted(date: .abbreviated, time: .shortened))
                }
            } header: {
                Text("Details")
            }
        }
        .navigationTitle(setList.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Set List", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingRecordView) {
            RecordSetView(setList: setList)
        }
        .alert("Delete Set List?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteSetList()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This set list will be permanently deleted. Recordings will remain but will no longer be associated with this set.")
        }
    }
    
    private func deleteSetList() {
        modelContext.delete(setList)
        dismiss()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}

#Preview {
    let container = try! ModelContainer(for: [Joke.self, SetList.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let joke1 = Joke(title: "Opening Joke", body: "This is my opener")
    let joke2 = Joke(title: "Story Time", body: "Here's a funny story")
    let joke3 = Joke(title: "Closer", body: "Thank you and good night!")
    
    container.mainContext.insert(joke1)
    container.mainContext.insert(joke2)
    container.mainContext.insert(joke3)
    
    let setList = SetList(name: "Open Mic Night", jokeOrder: [joke1.id, joke2.id, joke3.id])
    container.mainContext.insert(setList)
    
    return NavigationStack {
        SetListDetailView(setList: setList)
    }
    .modelContainer(container)
}
