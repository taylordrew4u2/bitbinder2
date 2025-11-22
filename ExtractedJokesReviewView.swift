//
//  ExtractedJokesReviewView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct ExtractedJokesReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var jokes: [ParsedJoke]
    let onComplete: () -> Void
    
    @State private var showingSuccessAlert = false
    @State private var savedCount = 0
    
    init(jokes: [ParsedJoke], onComplete: @escaping () -> Void) {
        _jokes = State(initialValue: jokes)
        self.onComplete = onComplete
    }
    
    private var selectedCount: Int {
        jokes.filter { $0.isSelected }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header info
                if !jokes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Found \(jokes.count) joke\(jokes.count == 1 ? "" : "s")")
                            .font(.headline)
                        Text("Review and edit before saving • Tap to expand")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                }
                
                // Jokes list
                List {
                    ForEach($jokes) { $joke in
                        ExtractedJokeRow(joke: $joke)
                    }
                    .onDelete(perform: deleteJokes)
                }
            }
            .navigationTitle("Review Jokes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Selected (\(selectedCount))") {
                        saveJokes()
                    }
                    .disabled(selectedCount == 0)
                    .fontWeight(.semibold)
                }
            }
            .alert("Jokes Saved", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    onComplete()
                }
            } message: {
                Text("Successfully added \(savedCount) joke\(savedCount == 1 ? "" : "s") to your library.")
            }
        }
    }
    
    private func deleteJokes(offsets: IndexSet) {
        jokes.remove(atOffsets: offsets)
    }
    
    private func saveJokes() {
        let selectedJokes = jokes.filter { $0.isSelected }
        
        for parsedJoke in selectedJokes {
            let joke = Joke(
                title: parsedJoke.title.isEmpty ? "Untitled Joke" : parsedJoke.title,
                body: parsedJoke.body
            )
            modelContext.insert(joke)
        }
        
        savedCount = selectedJokes.count
        showingSuccessAlert = true
    }
}

struct ExtractedJokeRow: View {
    @Binding var joke: ParsedJoke
    @State private var isExpanded = false
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: 12) {
                // Selection checkbox
                Button {
                    joke.isSelected.toggle()
                } label: {
                    Image(systemName: joke.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(joke.isSelected ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(joke.isSelected ? "Selected" : "Not selected")
                .accessibilityHint("Tap to toggle selection")
                
                // Content preview
                VStack(alignment: .leading, spacing: 4) {
                    Text(joke.title.isEmpty ? "Untitled Joke" : joke.title)
                        .font(.headline)
                        .foregroundStyle(joke.title.isEmpty ? .secondary : .primary)
                        .lineLimit(isExpanded ? nil : 2)
                    
                    if !joke.body.isEmpty && !isExpanded {
                        Text(joke.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Expand/collapse button
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
            }
            
            // Expanded view
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    if isEditing {
                        // Edit mode
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Title")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                TextField("Joke title", text: $joke.title, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(2...4)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Content")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                TextField("Joke content", text: $joke.body, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...10)
                            }
                            
                            Button("Done Editing") {
                                withAnimation {
                                    isEditing = false
                                }
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        // View mode
                        VStack(alignment: .leading, spacing: 12) {
                            if !joke.body.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Content")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(joke.body)
                                        .font(.subheadline)
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Label("Edit Joke", systemImage: "pencil")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    let sampleJokes = [
        ParsedJoke(
            title: "Airport Security",
            body: "I went through airport security and they asked me to remove my shoes. I said, 'Is this really necessary?' They said, 'Sir, you're not even at the airport yet, you're at a Walmart.'"
        ),
        ParsedJoke(
            title: "My Dog",
            body: "My dog is so lazy. The other day, a burglar broke in and my dog just lifted his head and said, 'He went that way.'"
        ),
        ParsedJoke(
            title: "Coffee Shop",
            body: "I asked the barista, 'What's the wifi password?' She said, 'You need to buy a drink first.' I said, 'Okay, I'll have a coffee.' She said, 'That'll be $4.' I said, 'For real? What's the wifi password?' She said, 'You need to buy a drink first.' No spaces, all lowercase."
        )
    ]
    
    let container = try! ModelContainer(
        for: Joke.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    return ExtractedJokesReviewView(jokes: sampleJokes) {}
        .modelContainer(container)
}
