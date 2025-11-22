# Joke Book Scanner Feature - Setup Guide

## Overview
The joke book scanner feature allows users to photograph their physical joke books and automatically extract the jokes using Apple's Vision framework. This guide covers the implementation and how to integrate it into your project.

## Files Added

### 1. TextRecognitionManager.swift
A manager class that uses Apple's Vision framework to:
- Extract text from images using OCR (Optical Character Recognition)
- Parse the extracted text into individual jokes
- Intelligently split text by paragraphs and numbered items
- Create title/body pairs for each joke

**Key Features:**
- Uses `VNRecognizeTextRequest` for accurate text recognition
- Sorts text observations top-to-bottom for proper reading order
- Handles errors gracefully with descriptive error messages
- Supports both numbered and unnumbered joke formats

### 2. JokeBookScannerView.swift
The main interface for capturing or selecting images:
- Camera button to take new photos
- Photo library picker to select existing images
- Progress indicator during processing
- Tips section for users to get best results
- Error handling with user-friendly alerts

**Key Features:**
- Uses `UIImagePickerController` for camera access
- Uses `PhotosPicker` for photo library access
- Automatic processing when image is captured/selected
- Navigates to review view when jokes are extracted

### 3. ExtractedJokesReviewView.swift
A review interface where users can:
- See all extracted jokes
- Expand/collapse each joke for detailed view
- Edit titles and content inline
- Select/deselect jokes before saving
- Delete unwanted jokes
- Save selected jokes to the library

**Key Features:**
- Expandable rows for detailed editing
- Inline text editors for quick fixes
- Selection checkboxes to choose which jokes to save
- Shows count of found jokes and selected jokes
- Batch save to SwiftData

## Integration

### Updated JokesView.swift
The jokes view now has a menu button instead of a simple add button:
- "Add Manually" option (existing functionality)
- "Scan Joke Book" option (new feature)

## Required Permissions

Add these to your Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to photograph your joke books and extract the text.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app accesses your photo library to extract jokes from images of your joke books.</string>
```

## Frameworks Used

- **Vision**: For text recognition (OCR)
- **PhotosUI**: For modern photo picker
- **UIKit**: For camera access via UIImagePickerController
- **SwiftUI**: For the user interface
- **SwiftData**: For saving extracted jokes

## How It Works

### 1. Text Extraction Flow
```
User captures/selects image 
  → TextRecognitionManager.extractText(from:)
  → VNRecognizeTextRequest processes image
  → Text observations sorted top-to-bottom
  → Raw text returned
```

### 2. Parsing Flow
```
Raw text
  → TextRecognitionManager.parseJokes(from:)
  → Split by double newlines (paragraphs)
  → Detect numbered jokes (1. 2.) 
  → Create title/body pairs
  → Return array of ParsedJoke
```

### 3. Review & Save Flow
```
ParsedJoke array
  → ExtractedJokesReviewView
  → User reviews/edits/selects jokes
  → Selected jokes converted to Joke models
  → Saved to SwiftData
  → Success alert shown
```

## Text Recognition Intelligence

The parser includes several smart features:

### Numbered Joke Detection
Recognizes patterns like:
- `1. Joke text here`
- `2) Another joke`
- `3 Third joke`

### Title Extraction
Creates titles from:
1. First line if short (<100 chars) and multi-line joke
2. First sentence if short (<100 chars)
3. First 50 characters with "..." if all else fails

### Paragraph Detection
- Splits by double newlines (common in formatted text)
- Falls back to single newlines if no paragraphs found
- Filters out very short lines (likely OCR noise)

## Usage Tips for Users

Best results when:
- Good, even lighting
- Text is straight and centered in frame
- Clear, readable font
- High contrast (dark text on light background)
- Camera held steady (not blurry)

## Accessibility

All views include:
- VoiceOver labels and hints
- Semantic button/control roles
- Descriptive system icons
- Support for Dynamic Type

## Testing Recommendations

1. **Test with various lighting conditions**
   - Bright light, dim light, natural vs artificial

2. **Test with different text formats**
   - Numbered lists
   - Paragraph-style jokes
   - Mixed formats

3. **Test with different paper types**
   - White paper
   - Colored paper
   - Glossy vs matte

4. **Test with different handwriting/fonts**
   - Printed text (best results)
   - Clear handwriting
   - Various font sizes

5. **Test error cases**
   - No text in image
   - Very blurry image
   - Low contrast

## Future Enhancements

Possible improvements:
- Support for multiple pages at once
- Bulk import from photo library
- Manual text entry fallback
- Custom parsing rules/templates
- Language selection for international users
- Confidence scoring for extracted text
- Batch editing of multiple jokes
- OCR preprocessing (rotation, contrast adjustment)

## Performance Notes

- Vision framework runs on-device (no network needed)
- Processing time depends on image size and complexity
- Typical processing: 1-3 seconds for a single page
- Results are immediately available (no cloud processing)

## Privacy & Security

- All processing happens on-device
- No data sent to external servers
- Images are not stored (only processed in memory)
- Extracted text stored locally in SwiftData
- No analytics or tracking

---

**Implementation Date:** November 22, 2025
**iOS Version:** 17.0+
**Swift Version:** 5.9+
