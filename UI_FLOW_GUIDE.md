# Joke Book Scanner - UI Flow & Screenshots Guide

## User Interface Flow

### 1️⃣ Entry Point: JokesView with Menu

```
┌─────────────────────────────────────┐
│  ← Jokes                         ⊕ │ ← Tap this!
├─────────────────────────────────────┤
│                                     │
│  🔍 Search jokes...                 │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📝 Airport Security           │ │
│  │    I went through airport...  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📝 My Dog                     │ │
│  │    My dog is so lazy...       │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘

When ⊕ is tapped, a menu appears:

┌─────────────────────────────┐
│ ➕ Add Manually             │
│ 📷 Scan Joke Book          │
└─────────────────────────────┘
```

---

### 2️⃣ JokeBookScannerView

```
┌─────────────────────────────────────┐
│ Cancel          Scan Jokes          │
├─────────────────────────────────────┤
│                                     │
│            📖                       │
│      (Large book icon)              │
│                                     │
│     Scan Your Joke Book             │
│                                     │
│  Take a photo or select an image   │
│  from your library. We'll extract   │
│  the jokes automatically.           │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   📷 Take Photo               │ │ ← Camera button
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   🖼️  Choose from Library     │ │ ← Photo library
│  └───────────────────────────────┘ │
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Tips for best results:         │ │
│  │                                │ │
│  │ 💡 Use good lighting          │ │
│  │ ✂️  Keep text straight and     │ │
│  │     centered                   │ │
│  │ 🔤 Make sure text is clear    │ │
│  │     and readable               │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘

When processing:

┌─────────────────────────────────────┐
│               ...                   │
│                                     │
│           ⊙ (spinner)               │
│      Extracting text...             │
│                                     │
└─────────────────────────────────────┘
```

---

### 3️⃣ ExtractedJokesReviewView (Collapsed)

```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes   Save (3)  │
├─────────────────────────────────────┤
│         Found 3 jokes               │
│  Review and edit before saving •    │
│        Tap to expand                │
├─────────────────────────────────────┤
│                                     │
│  ☑️  📝 Airport Security        ˅  │ ← Selected, collapsed
│      I went through airport...      │
│                                     │
│  ☑️  📝 My Dog                  ˅  │ ← Selected, collapsed
│      My dog is so lazy...           │
│                                     │
│  ⭕ 📝 Coffee Shop              ˅  │ ← Not selected, collapsed
│      I asked the barista...         │
│                                     │
└─────────────────────────────────────┘

Legend:
☑️ = Selected (will be saved)
⭕ = Not selected (will be skipped)
˅ = Tap to expand
```

---

### 4️⃣ ExtractedJokesReviewView (Expanded - View Mode)

```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes   Save (2)  │
├─────────────────────────────────────┤
│         Found 3 jokes               │
│  Review and edit before saving •    │
│        Tap to expand                │
├─────────────────────────────────────┤
│                                     │
│  ☑️  📝 Airport Security        ˄  │ ← Tap ˄ to collapse
│      I went through airport...      │
│      ──────────────────────         │
│      Content                        │
│      I went through airport         │
│      security and they asked me     │
│      to remove my shoes. I said,    │
│      'Is this really necessary?'    │
│      They said, 'Sir, you're not    │
│      even at the airport yet,       │
│      you're at a Walmart.'          │
│                                     │
│      [✏️ Edit Joke]                 │ ← Tap to edit
│                                     │
│  ☑️  📝 My Dog                  ˅  │
│      My dog is so lazy...           │
│                                     │
│  ⭕ 📝 Coffee Shop              ˅  │
│      I asked the barista...         │
│                                     │
└─────────────────────────────────────┘
```

---

### 5️⃣ ExtractedJokesReviewView (Expanded - Edit Mode)

```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes   Save (2)  │
├─────────────────────────────────────┤
│         Found 3 jokes               │
│  Review and edit before saving •    │
│        Tap to expand                │
├─────────────────────────────────────┤
│                                     │
│  ☑️  📝 Airport Security        ˄  │
│      I went through airport...      │
│      ──────────────────────         │
│      Title                          │
│      ┌─────────────────────────┐   │
│      │ Airport Security        │   │ ← Editable TextField
│      └─────────────────────────┘   │
│                                     │
│      Content                        │
│      ┌─────────────────────────┐   │
│      │ I went through airport  │   │
│      │ security and they asked │   │ ← Editable TextField
│      │ me to remove my shoes...│   │   (multiline)
│      └─────────────────────────┘   │
│                                     │
│      [Done Editing]                 │ ← Tap to finish
│                                     │
│  ☑️  📝 My Dog                  ˅  │
│      My dog is so lazy...           │
│                                     │
└─────────────────────────────────────┘
```

---

### 6️⃣ Success Alert

```
┌─────────────────────────────────────┐
│                                     │
│          Jokes Saved                │
│                                     │
│   Successfully added 2 jokes to     │
│        your library.                │
│                                     │
│            [  OK  ]                 │ ← Dismisses all sheets
│                                     │
└─────────────────────────────────────┘

After tapping OK, user returns to JokesView
and sees the newly added jokes in the list!
```

---

### 7️⃣ Error Alert (No Text Found)

```
┌─────────────────────────────────────┐
│                                     │
│            Error                    │
│                                     │
│   No text was found in the image.   │
│   Please try again with a clearer   │
│            photo.                   │
│                                     │
│            [  OK  ]                 │
│                                     │
└─────────────────────────────────────┘
```

---

## Interactive Elements

### Tap Areas in Review View

```
┌─────────────────────────────────────┐
│  [A] 📝 Title                  [B] │
│      Preview text...                │
│      ──────────────────────         │
│      Full content...                │
│      [C]                            │
└─────────────────────────────────────┘

[A] = Checkbox - Tap to toggle selection
[B] = Chevron - Tap to expand/collapse
[C] = Edit Button - Tap to enable editing
```

### Swipe Actions

```
← Swipe left on any joke

┌─────────────────────────────────────┐
│  ☑️  📝 Airport Sec... ˅      [🗑️]│ ← Delete button appears
└─────────────────────────────────────┘
```

---

## Camera Interface (System UI)

```
┌─────────────────────────────────────┐
│  Cancel                             │
│                                     │
│         📷 Camera View              │
│                                     │
│     (Live camera preview)           │
│                                     │
│                                     │
│              ⭕                     │ ← Capture button
│                                     │
└─────────────────────────────────────┘

After capture, automatically returns to 
JokeBookScannerView and processes the image.
```

---

## Photo Library Picker (System UI)

```
┌─────────────────────────────────────┐
│  Cancel           Photos             │
├─────────────────────────────────────┤
│                                     │
│  📁 Recents                 >       │
│  📁 Favorites              >       │
│  📁 Screenshots            >       │
│                                     │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐            │
│  │🖼️│ │🖼️│ │🖼️│ │🖼️│            │
│  └──┘ └──┘ └──┘ └──┘            │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐            │
│  │🖼️│ │🖼️│ │🖼️│ │🖼️│            │
│  └──┘ └──┘ └──┘ └──┘            │
│                                     │
└─────────────────────────────────────┘

Tap any photo to select. Returns to
JokeBookScannerView and processes it.
```

---

## Complete User Journey

```
1. User opens app
        ↓
2. Navigates to "Jokes"
        ↓
3. Taps "+" button
        ↓
4. Selects "Scan Joke Book" from menu
        ↓
5. Sees JokeBookScannerView
        ↓
6. Taps "Take Photo" or "Choose from Library"
        ↓
7. System shows camera/photo picker
        ↓
8. User captures or selects image
        ↓
9. App shows "Extracting text..." spinner
        ↓
10. ExtractedJokesReviewView appears with jokes
        ↓
11. User reviews jokes:
    - Expands to see full text
    - Taps "Edit" to fix any mistakes
    - Unchecks jokes they don't want
    - Swipes to delete bad extractions
        ↓
12. Taps "Save Selected (n)"
        ↓
13. Success alert appears
        ↓
14. Taps "OK"
        ↓
15. Returns to JokesView with new jokes!
```

---

## Visual States

### Loading State
```
┌─────────────────────────────────────┐
│                                     │
│           ⊙ (spinner)               │
│      Extracting text...             │
│                                     │
└─────────────────────────────────────┘
```

### Empty State (if no text found)
```
┌─────────────────────────────────────┐
│                                     │
│            ⚠️                       │
│                                     │
│         No Text Found               │
│                                     │
│    The image didn't contain any     │
│    readable text. Please try        │
│    again with a clearer photo.      │
│                                     │
│            [  OK  ]                 │
│                                     │
└─────────────────────────────────────┘
```

### Success State
```
┌─────────────────────────────────────┐
│                                     │
│            ✅                       │
│                                     │
│         Jokes Saved!                │
│                                     │
│    Successfully added 3 jokes       │
│       to your library.              │
│                                     │
│            [  OK  ]                 │
│                                     │
└─────────────────────────────────────┘
```

---

## Accessibility Features

### VoiceOver Labels

```
JokesView:
- "+" button → "Add jokes"
- Menu items → "Add Manually" / "Scan Joke Book"

JokeBookScannerView:
- Camera button → "Take Photo, Open camera to photograph your joke book"
- Library button → "Choose from Library, Select an existing photo from your library"

ExtractedJokesReviewView:
- Checkbox → "Selected" or "Not selected, Tap to toggle selection"
- Chevron → "Expand" or "Collapse"
- Edit button → "Edit Joke"
- Save button → "Save Selected, 3 jokes selected"
```

### Dynamic Type Support

All text scales with system font size settings:
- Headlines scale to .headline
- Body text scales to .body / .subheadline
- Buttons maintain minimum tap targets (44x44 points)

### High Contrast Mode

- All icons use system symbols (SF Symbols)
- Text uses semantic colors (.primary, .secondary)
- Buttons have sufficient contrast ratios
- Selected state is clearly visible

---

## Design Tokens

### Colors
- Primary: `.accentColor` (system blue)
- Secondary: `.secondary` (system gray)
- Success: `.green`
- Error: `.red`
- Background: `.systemBackground`
- Secondary Background: `.secondarySystemBackground`

### Spacing
- Card padding: 16pt
- Button padding: 16pt
- Row spacing: 12pt
- Section spacing: 20pt
- Icon size: 60pt (large), 44pt (standard), 20pt (small)

### Corner Radius
- Cards: 12pt
- Buttons: 12pt
- Text fields: System default (rounded border)

### Fonts
- Title: `.title2.bold()`
- Headline: `.headline`
- Body: `.subheadline`
- Caption: `.caption`

---

## Animation & Transitions

### Expand/Collapse
```swift
withAnimation {
    isExpanded.toggle()
}
```
- Duration: System default (~0.35s)
- Easing: Smooth spring animation

### Sheet Presentation
- System standard sheet animation
- Slides up from bottom
- Dimmed background overlay

### Progress Indicator
- Indeterminate spinner
- Scales to 1.2x normal size
- Smooth rotation animation

---

## Edge Cases UI

### Single Joke Found
```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes   Save (1)  │
├─────────────────────────────────────┤
│          Found 1 joke               │ ← Singular
│  Review and edit before saving •    │
│        Tap to expand                │
├─────────────────────────────────────┤
│  ☑️  📝 Airport Security        ˅  │
│      I went through airport...      │
└─────────────────────────────────────┘
```

### Many Jokes Found
```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes  Save (15)  │
├─────────────────────────────────────┤
│         Found 15 jokes              │
│  Review and edit before saving •    │
│        Tap to expand                │
├─────────────────────────────────────┤
│  (Scrollable list)                  │
│  ☑️  📝 Joke 1                  ˅  │
│  ☑️  📝 Joke 2                  ˅  │
│  ☑️  📝 Joke 3                  ˅  │
│  ...                                │
└─────────────────────────────────────┘
```

### No Jokes Selected
```
┌─────────────────────────────────────┐
│ Cancel     Review Jokes   Save (0)  │ ← Button disabled
├─────────────────────────────────────┤
│  ⭕ 📝 Joke 1                   ˅  │ ← All unchecked
│  ⭕ 📝 Joke 2                   ˅  │
│  ⭕ 📝 Joke 3                   ˅  │
└─────────────────────────────────────┘

Save button is grayed out and non-interactive.
```

---

This UI flow provides a smooth, intuitive experience for users to
digitize their physical joke books with minimal effort! 📸✨

