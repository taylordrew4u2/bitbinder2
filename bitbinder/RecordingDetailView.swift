//
//  RecordingDetailView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct RecordingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let recording: Recording
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingDeleteAlert = false
    @State private var notesText: String
    @State private var showingShareSheet = false
    
    init(recording: Recording) {
        self.recording = recording
        _notesText = State(initialValue: recording.notes ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Audio Player Section
                VStack(spacing: 16) {
                    // Progress Bar
                    VStack(spacing: 8) {
                        ProgressView(value: currentTime, total: recording.durationSec)
                            .tint(.accentColor)
                        
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text(formatTime(recording.durationSec))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    
                    // Playback Controls
                    HStack(spacing: 40) {
                        Button(action: skipBackward) {
                            Image(systemName: "gobackward.15")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Skip back 15 seconds")
                        
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(.accentColor)
                        }
                        .accessibilityLabel(isPlaying ? "Pause" : "Play")
                        
                        Button(action: skipForward) {
                            Image(systemName: "goforward.15")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Skip forward 15 seconds")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Recording Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recording Details")
                        .font(.headline)
                    
                    InfoRow(label: "Set List", value: recording.setListName)
                    InfoRow(label: "Duration", value: formatTime(recording.durationSec))
                    InfoRow(label: "Recorded", value: recording.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)
                    
                    TextEditor(text: $notesText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: notesText) { _, newValue in
                            saveNotes(newValue)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share Recording", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Recording")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Recording", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopPlayback()
        }
        .alert("Delete Recording?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteRecording()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This recording will be permanently deleted.")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = try? recording.fileURL.checkResourceIsReachable() ? recording.fileURL : nil {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    private func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            timer?.invalidate()
        } else {
            player.play()
            startTimer()
        }
        
        isPlaying.toggle()
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        timer?.invalidate()
        isPlaying = false
    }
    
    private func skipForward() {
        guard let player = audioPlayer else { return }
        player.currentTime = min(player.currentTime + 15, player.duration)
        currentTime = player.currentTime
    }
    
    private func skipBackward() {
        guard let player = audioPlayer else { return }
        player.currentTime = max(player.currentTime - 15, 0)
        currentTime = player.currentTime
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = audioPlayer {
                currentTime = player.currentTime
                
                if !player.isPlaying {
                    isPlaying = false
                    timer?.invalidate()
                }
            }
        }
    }
    
    private func saveNotes(_ text: String) {
        recording.addNotes(text)
    }
    
    private func deleteRecording() {
        // Delete the audio file
        try? FileManager.default.removeItem(at: recording.fileURL)
        
        // Delete from database
        modelContext.delete(recording)
        dismiss()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let container = try! ModelContainer(for: Recording.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let recording = Recording(
        setListId: UUID(),
        setListName: "Friday Night Show",
        fileURL: URL(fileURLWithPath: "/tmp/recording.m4a"),
        durationSec: 325
    )
    recording.addNotes("Great audience response. Need to work on timing for joke #3.")
    
    container.mainContext.insert(recording)
    
    return NavigationStack {
        RecordingDetailView(recording: recording)
    }
    .modelContainer(container)
}
