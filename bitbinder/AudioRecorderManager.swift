//
//  AudioRecorderManager.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import AVFoundation
import Combine

@MainActor
class AudioRecorderManager: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingFileURL: URL?
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingTime: TimeInterval = 0
    @Published var recordingError: String?
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            recordingError = "Audio session setup failed: \(error.localizedDescription)"
        }
    }
    
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func startRecording(setListName: String) async -> URL? {
        let hasPermission = await requestPermission()
        guard hasPermission else {
            recordingError = "Microphone permission denied. Please enable in Settings."
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "\(setListName)_\(timestamp).m4a"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            isPaused = false
            recordingTime = 0
            recordingError = nil
            recordingFileURL = fileURL
            
            startTimer()
            return fileURL
        } catch {
            recordingError = "Recording failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    func pauseRecording() {
        audioRecorder?.pause()
        isPaused = true
        timer?.invalidate()
    }
    
    func resumeRecording() {
        audioRecorder?.record()
        isPaused = false
        startTimer()
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        isPaused = false
        
        let url = recordingFileURL
        recordingFileURL = nil
        return url
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        isPaused = false
        
        // Delete the file
        if let fileURL = recordingFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        recordingFileURL = nil
        recordingTime = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.recordingTime += 1
            }
        }
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                recordingError = "Recording failed to save"
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            recordingError = "Recording error: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}
