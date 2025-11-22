# Comedy Set Organizer

A complete iOS app for comedians to manage jokes, create set lists, and record performances.

## 🎯 Features

- **Joke Library**: Store and organize all your comedy material
- **Set List Builder**: Create performance sets by selecting and reordering jokes
- **Audio Recording**: Record your performances with high-quality audio
- **Performance Notes**: Track what works and needs improvement
- **100% Local**: No sign-in required, no tracking, works completely offline
- **Accessibility**: Full VoiceOver and Dynamic Type support

## 📱 Project Structure

### Data Models (SwiftData)
- `Joke.swift` - Individual joke with title and content
- `SetList.swift` - Ordered collection of jokes for performances
- `Recording.swift` - Audio recordings of performances with metadata

### Views
- `HomeView.swift` - Main navigation hub
- `JokesView.swift` - Browse and manage joke library
- `AddEditJokeView.swift` - Create/edit individual jokes
- `JokeDetailView.swift` - View joke details
- `CreateSetListView.swift` - Build new set lists
- `SetListsView.swift` - Browse saved set lists
- `SetListDetailView.swift` - View set list details
- `RecordSetView.swift` - Audio recording interface
- `RecordingsView.swift` - Browse recorded performances
- `RecordingDetailView.swift` - Playback and review recordings
- `EmptyStateView.swift` - Reusable empty state component

### Managers
- `AudioRecorderManager.swift` - Handles audio recording with AVFoundation

## 🔧 Setup Instructions

### 1. Required Info.plist Entries

Add the microphone usage description to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app records your performance audio when you choose to record a set.</string>
```

### 2. Build Settings

**Target:** iOS 17.0+
**Swift Version:** Swift 5.9+
**Frameworks:**
- SwiftUI
- SwiftData
- AVFoundation

### 3. File Organization in Xcode

Organize your files into groups:

```
bitbinder/
├── App/
│   ├── bitbinderApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Joke.swift
│   ├── SetList.swift
│   └── Recording.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Jokes/
│   │   ├── JokesView.swift
│   │   ├── AddEditJokeView.swift
│   │   └── JokeDetailView.swift
│   ├── SetLists/
│   │   ├── CreateSetListView.swift
│   │   ├── SetListsView.swift
│   │   └── SetListDetailView.swift
│   ├── Recordings/
│   │   ├── RecordSetView.swift
│   │   ├── RecordingsView.swift
│   │   └── RecordingDetailView.swift
│   └── Components/
│       └── EmptyStateView.swift
└── Managers/
    └── AudioRecorderManager.swift
```

## 🚀 Usage Guide

### Managing Jokes

1. **Add a Joke**
   - Tap "Jokes" from home screen
   - Tap the "+" button
   - Enter title (required) and content (optional)
   - Tap "Save"

2. **Edit/Delete a Joke**
   - Tap on any joke to view details
   - Tap the "..." menu for options
   - Choose "Edit" or "Delete"

3. **Search Jokes**
   - Use the search bar to filter by title or content

### Creating Set Lists

1. **Build a New Set**
   - Tap "Create Set List" from home
   - Enter a set name
   - Tap jokes to add them to your set
   - Drag jokes in the "Selected Jokes" section to reorder
   - Swipe to remove jokes
   - Tap "Save" when done

2. **View Set Lists**
   - Tap "Set Lists" from home
   - See all your saved sets with joke count and last performed date
   - Tap any set to view details

### Recording Performances

1. **Record a Set**
   - Open a set list
   - Tap "Record This Set"
   - Grant microphone permission if prompted
   - Tap "Start Recording"
   - Use pause/resume as needed
   - Tap "Stop" when finished

2. **Review Recordings**
   - Tap "Recordings" from home
   - Tap any recording to play it
   - Use skip forward/backward buttons
   - Add notes about your performance
   - Share recordings via the share button

## 📋 App Store Metadata

### Name
**Comedy Set Organizer**

### Subtitle
Write jokes, build sets, record, review

### Description
Comedy Set Organizer helps comedians manage their material and performances. Store your jokes in one organized library, build set lists by dragging and dropping jokes into your preferred order, record your performances with high-quality audio, and add notes to track what works.

FEATURES:
• Joke Library - Store and organize all your comedy material
• Set List Builder - Create performance sets by reordering jokes
• Audio Recorder - Record your sets with professional quality
• Performance Notes - Track what works and needs improvement
• 100% Local - No sign-in required, no tracking, works offline
• Accessibility - Full VoiceOver and Dynamic Type support

Perfect for open mics, rehearsals, and tracking your comedy journey. Your data stays on your device—private and secure.

### Keywords
comedy, jokes, standup, set list, recorder, notes, open mic

### Privacy
- **Data Collection**: None
- **Data Storage**: 100% on-device
- **Tracking**: None
- **Age Rating**: 4+

## 🔐 Privacy Policy

This app:
- ✅ Does NOT collect any personal data
- ✅ Stores everything locally on your device
- ✅ Never transmits data to servers
- ✅ Uses microphone only when you record (with permission)
- ✅ Allows you to share recordings via iOS share sheet (your choice)

## ♿️ Accessibility Features

- Full VoiceOver support with descriptive labels
- Dynamic Type support for text scaling
- High contrast support
- Semantic HTML for web content
- Keyboard navigation support
- Descriptive button labels

## 🐛 Known Issues / Future Enhancements

### Current Limitations
- Recordings are stored in app documents directory
- No iCloud sync (intentional for privacy)
- No export/import of joke library

### Potential Enhancements
- Timer during recording to show expected set time
- Statistics (total sets, recording time, etc.)
- Tags/categories for jokes
- Export joke library as text file
- Custom set list templates

## 📄 License

This is a complete implementation ready for personal use or App Store submission.

## 🤝 Contributing

This project is designed as a complete, production-ready app. Feel free to:
- Customize colors and styling
- Add features that suit your workflow
- Improve accessibility
- Optimize performance

## 📞 Support

For questions or issues:
- Check this README for setup instructions
- Review SwiftData and AVFoundation documentation
- Test on real device for microphone/audio features

---

**Built with:**
- SwiftUI for modern, declarative UI
- SwiftData for persistence
- AVFoundation for audio recording/playback
- Swift Concurrency (async/await) for permissions

**Target:** iOS 17.0+
**Created:** November 22, 2025
