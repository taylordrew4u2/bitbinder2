//
//  AddEditJokeView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct AddEditJokeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let joke: Joke?
    
    @State private var title: String
    @State private var body: String
    @State private var showingValidationAlert = false
    
    init(joke: Joke? = nil) {
        self.joke = joke
        _title = State(initialValue: joke?.title ?? "")
        _body = State(initialValue: joke?.body ?? "")
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Joke Title", text: $title)
                        .accessibilityLabel("Joke title")
                } header: {
                    Text("Title")
                } footer: {
                    Text("Required: A short title for this joke")
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    TextEditor(text: $body)
                        .frame(minHeight: 200)
                        .accessibilityLabel("Joke content")
                } header: {
                    Text("Content")
                } footer: {
                    Text("Optional: The full text of your joke")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(joke == nil ? "Add Joke" : "Edit Joke")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJoke()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveJoke() {
        guard isValid else {
            showingValidationAlert = true
            return
        }
        
        if let joke = joke {
            // Edit existing joke
            joke.update(title: title, body: body)
        } else {
            // Create new joke
            let newJoke = Joke(title: title, body: body)
            modelContext.insert(newJoke)
        }
        
        dismiss()
    }
}

#Preview("Add Joke") {
    AddEditJokeView()
        .modelContainer(for: [Joke.self], inMemory: true)
}

#Preview("Edit Joke") {
    let container = try! ModelContainer(for: Joke.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let joke = Joke(title: "Sample Joke", body: "This is a funny joke")
    container.mainContext.insert(joke)
    
    return AddEditJokeView(joke: joke)
        .modelContainer(container)
}
