# Joke Book Scanner - Architecture Overview

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         JokesView                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Toolbar "+" Menu                                         │  │
│  │  ├─ Add Manually → AddEditJokeView (existing)           │  │
│  │  └─ Scan Joke Book → JokeBookScannerView (NEW)          │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ presents sheet
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                   JokeBookScannerView                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Two Options:                                             │  │
│  │  ├─ [Take Photo] → UIImagePickerController (Camera)     │  │
│  │  └─ [Choose from Library] → PhotosPicker                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  @StateObject var recognitionManager                      │  │
│  │  = TextRecognitionManager()                               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ image selected
                                    ▼
                        processImage(UIImage) async
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                  TextRecognitionManager                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  extractText(from: UIImage) async throws → String        │  │
│  │                                                            │  │
│  │  Uses Vision Framework:                                   │  │
│  │  • VNRecognizeTextRequest                                │  │
│  │  • VNRecognizedTextObservation                           │  │
│  │  • Sorts observations top-to-bottom                      │  │
│  │  • Joins text with proper line breaks                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  parseJokes(from: String) → [ParsedJoke]                 │  │
│  │                                                            │  │
│  │  Smart Parsing:                                           │  │
│  │  • Splits by double newlines (paragraphs)                │  │
│  │  • Detects numbered jokes (1. 2. 3.)                     │  │
│  │  • Extracts titles from first line/sentence              │  │
│  │  • Filters out noise (very short text)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ jokes parsed
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│               ExtractedJokesReviewView                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  @State var jokes: [ParsedJoke]                          │  │
│  │                                                            │  │
│  │  struct ParsedJoke:                                       │  │
│  │  • id: UUID                                               │  │
│  │  • title: String                                          │  │
│  │  • body: String                                           │  │
│  │  • isSelected: Bool                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  List of ExtractedJokeRow:                                │  │
│  │  • Checkbox for selection                                 │  │
│  │  • Expand/collapse button                                 │  │
│  │  • Edit mode with TextField editors                       │  │
│  │  • Delete via swipe or onDelete                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Save Button (shows count of selected)                    │  │
│  │  • Converts ParsedJoke → Joke models                     │  │
│  │  • Inserts into modelContext (SwiftData)                 │  │
│  │  • Shows success alert                                    │  │
│  │  • Calls onComplete() → dismisses all sheets             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ saved to database
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SwiftData Storage                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  @Model class Joke:                                       │  │
│  │  • id: UUID                                               │  │
│  │  • title: String                                          │  │
│  │  • body: String                                           │  │
│  │  • createdAt: Date                                        │  │
│  │  • updatedAt: Date                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
User Action
    │
    ├─ Tap "+" in JokesView
    │      │
    │      ├─ Select "Add Manually" → [Existing Flow]
    │      │
    │      └─ Select "Scan Joke Book"
    │              │
    │              ▼
    │         JokeBookScannerView
    │              │
    │              ├─ "Take Photo" → Camera → UIImage
    │              │
    │              └─ "Choose from Library" → PhotosPicker → UIImage
    │                      │
    │                      ▼
    │              processImage(UIImage)
    │                      │
    │                      ▼
    │         TextRecognitionManager.extractText()
    │                      │
    │                      ├─ Create VNRecognizeTextRequest
    │                      ├─ Process with VNImageRequestHandler
    │                      ├─ Get VNRecognizedTextObservation[]
    │                      ├─ Sort by vertical position
    │                      └─ Join into String
    │                      │
    │                      ▼
    │                  Raw Text String
    │                      │
    │                      ▼
    │         TextRecognitionManager.parseJokes()
    │                      │
    │                      ├─ Split by paragraphs
    │                      ├─ Detect numbered jokes
    │                      ├─ Extract title/body pairs
    │                      └─ Create ParsedJoke[]
    │                      │
    │                      ▼
    │              [ParsedJoke] Array
    │                      │
    │                      ▼
    │         ExtractedJokesReviewView
    │                      │
    │                      ├─ Display in List
    │                      ├─ Allow expand/edit
    │                      ├─ Allow select/deselect
    │                      └─ Allow delete
    │                      │
    │                      ▼
    │         User taps "Save Selected"
    │                      │
    │                      ├─ Filter by isSelected
    │                      ├─ Convert to Joke models
    │                      ├─ Insert into modelContext
    │                      └─ Show success alert
    │                      │
    │                      ▼
    │              Jokes saved to SwiftData
    │                      │
    │                      ▼
    └─────────────> JokesView (automatically refreshes via @Query)
```

## State Management

### JokesView
```swift
@State private var showingScanner: Bool
```

### JokeBookScannerView
```swift
@StateObject private var recognitionManager: TextRecognitionManager
@State private var selectedImage: PhotosPickerItem?
@State private var capturedImage: UIImage?
@State private var showingCamera: Bool
@State private var parsedJokes: [ParsedJoke]
@State private var showingReviewView: Bool
@State private var showingError: Bool
```

### TextRecognitionManager
```swift
@Published var isProcessing: Bool
@Published var error: TextRecognitionError?
```

### ExtractedJokesReviewView
```swift
@State private var jokes: [ParsedJoke]
@State private var showingSuccessAlert: Bool
@State private var savedCount: Int
```

### ExtractedJokeRow
```swift
@Binding var joke: ParsedJoke
@State private var isExpanded: Bool
@State private var isEditing: Bool
```

## Framework Dependencies

```
┌─────────────────────────────────────────┐
│           App Layer                      │
│  • JokesView                            │
│  • JokeBookScannerView                  │
│  • ExtractedJokesReviewView             │
└─────────────────────────────────────────┘
                  │
                  │ uses
                  ▼
┌─────────────────────────────────────────┐
│         Manager Layer                    │
│  • TextRecognitionManager               │
└─────────────────────────────────────────┘
                  │
                  │ uses
                  ▼
┌─────────────────────────────────────────┐
│      Apple Frameworks                    │
│  • Vision (VNRecognizeTextRequest)      │
│  • PhotosUI (PhotosPicker)              │
│  • UIKit (UIImagePickerController)      │
│  • SwiftUI (Views, State, Binding)      │
│  • SwiftData (ModelContext, @Model)     │
└─────────────────────────────────────────┘
```

## Error Handling Flow

```
Error Source → Detection → User Notification

Image Processing Error
    │
    ├─ CGImage creation fails
    │      └─> TextRecognitionError.processingFailed
    │
    ├─ Vision request fails
    │      └─> TextRecognitionError.processingFailed
    │
    └─ No text recognized
           └─> TextRecognitionError.noTextFound
                   │
                   ▼
            JokeBookScannerView
                   │
                   └─> .alert("Error", ...)
                           │
                           └─> User sees friendly message
```

## Permission Flow

```
First Use
    │
    ├─ User taps "Take Photo"
    │      │
    │      └─> System shows camera permission alert
    │             │
    │             ├─ Allow → Camera opens
    │             └─ Deny → Permission denied (handled by system)
    │
    └─ User taps "Choose from Library"
           │
           └─> System shows photo library permission alert
                  │
                  ├─ Allow → Photo picker opens
                  └─ Deny → Permission denied (handled by system)

Info.plist Keys Required:
• NSCameraUsageDescription
• NSPhotoLibraryUsageDescription
```

## Performance Considerations

| Operation | Time | Thread | Notes |
|-----------|------|--------|-------|
| Image capture | Instant | Main | System handled |
| Photo selection | Instant | Main | System handled |
| Text extraction | 1-3s | Background | Vision framework |
| Text parsing | <100ms | Main | Pure Swift logic |
| UI rendering | Instant | Main | SwiftUI efficient |
| Database save | <100ms | Main | SwiftData optimized |

---

**Key Architectural Decisions:**

1. **Separation of Concerns**: Manager handles OCR, Views handle UI
2. **Async/Await**: Modern concurrency for Vision processing
3. **Observable Objects**: Real-time processing status updates
4. **ParsedJoke Model**: Temporary model before saving to database
5. **Inline Editing**: User can fix OCR errors before saving
6. **Batch Operations**: Save multiple jokes at once efficiently

