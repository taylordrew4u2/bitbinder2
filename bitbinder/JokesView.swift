//
//  JokesView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct JokesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Joke.updatedAt, order: .reverse) private var jokes: [Joke]
    
    @State private var searchText = ""
    @State private var showingAddJoke = false
    
    private var filteredJokes: [Joke] {
        if searchText.isEmpty {
            return jokes
        }
        return jokes.filter { joke in
            joke.title.localizedCaseInsensitiveContains(searchText) ||
            joke.body.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if jokes.isEmpty {
                EmptyStateView(
                    title: "No Jokes Yet",
                    message: "Add your first joke to get started",
                    icon: "text.bubble"
                )
            } else {
                List {
                    ForEach(filteredJokes) { joke in
                        NavigationLink(destination: JokeDetailView(joke: joke)) {
                            JokeRowView(joke: joke)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .onDelete(perform: deleteJokes)
                }
                .searchable(text: $searchText, prompt: "Search jokes...")
            }
        }
        .navigationTitle("Jokes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddJoke = true }) {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add new joke")
                }
            }
        }
        .sheet(isPresented: $showingAddJoke) {
            AddEditJokeView()
        }
    }
    
    private func deleteJokes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredJokes[index])
            }
        }
    }
}

struct JokeRowView: View {
    let joke: Joke
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(joke.title)
                .font(.headline)
                .lineLimit(1)
            
            if !joke.body.isEmpty {
                Text(joke.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        JokesView()
    }
    .modelContainer(for: [Joke.self], inMemory: true)
}
