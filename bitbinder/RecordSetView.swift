//
//  RecordSetView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData

struct RecordSetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allJokes: [Joke]
    
    let setList: SetList
    @StateObject private var audioRecorder = AudioRecorderManager()
    @State private var showingDiscardAlert = false
    @State private var recordingFileURL: URL?
    
    private var jokes: [Joke] {
        setList.jokeOrder.compactMap { jokeId in
            allJokes.first(where: { $0.id == jokeId })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Timer Display
                VStack(spacing: 10) {
                    Text(formatTime(audioRecorder.recordingTime))
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                    
                    if audioRecorder.isPaused {
                        Text("Paused")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Recording time: \(formatTimeAccessibility(audioRecorder.recordingTime))")
                
                // Recording Controls
                HStack(spacing: 40) {
                    if !audioRecorder.isRecording {
                        Button(action: startRecording) {
                            RecordButton(label: "Start Recording", systemImage: "record.circle")
                        }
                        .accessibilityHint("Begin recording your set")
                    } else {
                        if audioRecorder.isPaused {
                            Button(action: audioRecorder.resumeRecording) {
                                RecordButton(label: "Resume", systemImage: "play.circle")
                            }
                        } else {
                            Button(action: audioRecorder.pauseRecording) {
                                RecordButton(label: "Pause", systemImage: "pause.circle")
                            }
                        }
                        
                        Button(action: stopRecording) {
                            RecordButton(label: "Stop", systemImage: "stop.circle", color: .red)
                        }
                    }
                }
                
                // Set List Preview
                if !jokes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set List Order")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(jokes.enumerated()), id: \.element.id) { index, joke in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 25, alignment: .trailing)
                                        
                                        Text(joke.title)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Record Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(audioRecorder.isRecording ? "Cancel" : "Done") {
                        if audioRecorder.isRecording {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Discard Recording?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    audioRecorder.cancelRecording()
                    dismiss()
                }
                Button("Continue Recording", role: .cancel) {}
            } message: {
                Text("This recording will be permanently deleted.")
            }
            .alert("Error", isPresented: .constant(audioRecorder.recordingError != nil)) {
                Button("OK") {
                    audioRecorder.recordingError = nil
                }
            } message: {
                if let error = audioRecorder.recordingError {
                    Text(error)
                }
            }
        }
    }
    
    private func startRecording() {
        Task {
            if let fileURL = await audioRecorder.startRecording(setListName: setList.name) {
                recordingFileURL = fileURL
            }
        }
    }
    
    private func stopRecording() {
        guard let fileURL = audioRecorder.stopRecording() else { return }
        
        let recording = Recording(
            setListId: setList.id,
            setListName: setList.name,
            fileURL: fileURL,
            durationSec: audioRecorder.recordingTime
        )
        
        modelContext.insert(recording)
        
        // Update set list's last performed date
        setList.lastPerformedAt = Date()
        
        dismiss()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatTimeAccessibility(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return "\(minutes) minutes \(seconds) seconds"
    }
}

struct RecordButton: View {
    let label: String
    let systemImage: String
    var color: Color = .accentColor
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
        }
        .frame(width: 100, height: 100)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    let container = try! ModelContainer(for: [Joke.self, SetList.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let joke1 = Joke(title: "Opening Joke")
    let joke2 = Joke(title: "Middle Bit")
    let joke3 = Joke(title: "Closing")
    
    container.mainContext.insert(joke1)
    container.mainContext.insert(joke2)
    container.mainContext.insert(joke3)
    
    let setList = SetList(name: "Comedy Show", jokeOrder: [joke1.id, joke2.id, joke3.id])
    container.mainContext.insert(setList)
    
    return RecordSetView(setList: setList)
        .modelContainer(container)
}
