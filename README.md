# Mac Cleaner

I tend to accumulate a lot of files in common directories and periodically need to clear them out. Mac Cleaner makes that process fast — open a folder, review each file one by one, and delete what you don't need.

## How it works

Pick a folder and step through each file using the keyboard:

| Key | Action |
|-----|--------|
| `k` | Keep |
| `d` | Mark for deletion |
| `b` | Go back to the previous file |

Once you've reviewed everything, confirm which files to trash or permanently delete.

## Technical overview

A minimal macOS SwiftUI app. Navigation is driven by a simple enum state machine (`picking → reviewing → summary`). File preview uses QuickLook with a background preloader to keep transitions instant. Deletion goes through `FileManager` with sandbox entitlements for user-selected files.

- **Language:** Swift
- **UI:** SwiftUI
- **Deployment target:** macOS 26.3
- **No third-party dependencies**

## Building

Open `Mac Cleaner.xcodeproj` in Xcode and run, or from the terminal:

```bash
xcodebuild -project "Mac Cleaner.xcodeproj" -scheme "Mac Cleaner" build
```
