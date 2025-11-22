# GitHub Setup Guide

## Quick Start: Push Your Project to GitHub

### Option 1: Using Xcode (Recommended)

1. **Initialize Git Repository** (if not already done)
   - In Xcode, go to **Source Control** → **New Git Repositories...**
   - Select your `bitbinder` project
   - Click **Create**

2. **Create Repository on GitHub**
   - Go to [github.com](https://github.com) and sign in
   - Click the **+** button → **New repository**
   - Name it: `comedy-set-organizer` (or `bitbinder`)
   - **Do NOT** initialize with README (we already have files)
   - Click **Create repository**

3. **Connect Xcode to GitHub**
   - In Xcode, go to **Settings** → **Accounts**
   - Click **+** → Select **GitHub**
   - Sign in with your GitHub account

4. **Add Remote and Push**
   - In Xcode, go to **Source Control** → **Push...**
   - If no remote exists, click **Add Remote**
   - Select your GitHub account and the repository you created
   - Click **Push**

### Option 2: Using Terminal

```bash
# Navigate to your project directory
cd /path/to/bitbinder

# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Comedy Set Organizer complete implementation"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR_USERNAME/comedy-set-organizer.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Recommended .gitignore

Create a `.gitignore` file in your project root with:

```gitignore
# Xcode
*.xcuserstate
*.xcworkspace/xcuserdata/
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.swiftpm/
.build/

# CocoaPods (if you use it)
Pods/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Recordings (optional - if you don't want to commit test recordings)
*.m4a

# macOS
.DS_Store
```

## Repository Setup Checklist

- [ ] Initialize Git repository
- [ ] Create `.gitignore` file
- [ ] Create initial commit
- [ ] Create GitHub repository
- [ ] Connect remote
- [ ] Push code
- [ ] Add repository description on GitHub
- [ ] Add topics: `swift`, `swiftui`, `ios`, `comedy`, `standup`
- [ ] Set repository visibility (public or private)

## Best Practices

### Commit Messages
Use clear, descriptive commit messages:
```bash
git commit -m "Add joke management features"
git commit -m "Implement audio recording with AVFoundation"
git commit -m "Fix: Recording timer not stopping on pause"
```

### Branching Strategy
```bash
# Create feature branches for new work
git checkout -b feature/add-joke-categories
git checkout -b fix/recording-crash

# Merge back to main when complete
git checkout main
git merge feature/add-joke-categories
```

### Regular Pushes
```bash
# Stage changes
git add .

# Commit with message
git commit -m "Your descriptive message"

# Push to GitHub
git push
```

## Protecting Sensitive Information

### Never commit:
- API keys or secrets
- Personal information
- Test recordings with real content
- Database files with real data

### If you accidentally committed sensitive data:
```bash
# Remove file from git but keep locally
git rm --cached SensitiveFile.swift

# Add to .gitignore
echo "SensitiveFile.swift" >> .gitignore

# Commit the removal
git commit -m "Remove sensitive file from tracking"

# Push
git push
```

## GitHub Repository Description

**Description:**
```
iOS app for comedians to manage jokes, create set lists, and record performances. 
Built with SwiftUI, SwiftData, and AVFoundation. 100% local, no data collection.
```

**Topics:**
- swift
- swiftui
- swiftdata
- ios
- comedy
- standup
- audio-recording
- privacy-focused

## README Badge Ideas

Add these to your GitHub README for polish:

```markdown
![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-green)
```

## Next Steps After Initial Push

1. **Enable GitHub Actions** (optional)
   - Set up automated builds
   - Run tests on push

2. **Add Documentation**
   - Screenshots
   - Demo video
   - API documentation

3. **Track Issues**
   - Use GitHub Issues for bugs
   - Use Projects for roadmap

4. **Releases**
   - Tag versions: `v1.0.0`
   - Create releases for App Store submissions

## Common Git Commands

```bash
# Check status
git status

# View commit history
git log --oneline

# Create new branch
git checkout -b feature-name

# Switch branches
git checkout main

# Pull latest changes
git pull

# Stash changes temporarily
git stash
git stash pop

# Undo last commit (keep changes)
git reset --soft HEAD~1

# View changes
git diff
```

---

**Ready to Push?**

Run this quick check:
```bash
# Make sure you're in the project directory
pwd

# Check git status
git status

# See what will be committed
git diff --staged

# All good? Push it!
git push
```
