//
//  JokeDetailView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct JokeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let joke: Joke
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(joke.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                if !joke.body.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        Text(joke.body)
                            .font(.body)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created: \(joke.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Updated: \(joke.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Joke Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditJokeView(joke: joke)
        }
        .alert("Delete Joke?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteJoke()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This joke will be permanently deleted and removed from all set lists.")
        }
    }
    
    private func deleteJoke() {
        modelContext.delete(joke)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: Joke.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let joke = Joke(title: "Why did the chicken cross the road?", body: "To get to the other side! Classic comedy gold.")
    container.mainContext.insert(joke)
    
    return NavigationStack {
        JokeDetailView(joke: joke)
    }
    .modelContainer(container)
}
