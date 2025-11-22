//
//  JokeBookScannerView.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import SwiftUI
import PhotosUI

struct JokeBookScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recognitionManager = TextRecognitionManager()
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var extractedText: String?
    @State private var parsedJokes: [ParsedJoke] = []
    @State private var showingReviewView = false
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                    
                    Text("Scan Your Joke Book")
                        .font(.title2.bold())
                    
                    Text("Take a photo or select an image from your library. We'll extract the jokes automatically.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityHint("Open camera to photograph your joke book")
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityHint("Select an existing photo from your library")
                }
                .padding(.horizontal)
                
                // Processing indicator
                if recognitionManager.isProcessing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Extracting text...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips for best results:")
                        .font(.subheadline.bold())
                    
                    TipRow(icon: "lightbulb", text: "Use good lighting")
                    TipRow(icon: "crop", text: "Keep text straight and centered")
                    TipRow(icon: "textformat.size", text: "Make sure text is clear and readable")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Scan Jokes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { image in
                    capturedImage = image
                    showingCamera = false
                    Task {
                        await processImage(image)
                    }
                }
            }
            .sheet(isPresented: $showingReviewView) {
                if !parsedJokes.isEmpty {
                    ExtractedJokesReviewView(jokes: parsedJokes) {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = recognitionManager.error {
                    Text(error.localizedDescription)
                }
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await processImage(image)
                    }
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) async {
        do {
            let text = try await recognitionManager.extractText(from: image)
            extractedText = text
            parsedJokes = recognitionManager.parseJokes(from: text)
            
            if !parsedJokes.isEmpty {
                showingReviewView = true
            } else {
                recognitionManager.error = .noTextFound
                showingError = true
            }
        } catch {
            if let recognitionError = error as? TextRecognitionManager.TextRecognitionError {
                recognitionManager.error = recognitionError
            } else {
                recognitionManager.error = .processingFailed(error.localizedDescription)
            }
            showingError = true
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// Camera View using UIImagePickerController
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    JokeBookScannerView()
}
