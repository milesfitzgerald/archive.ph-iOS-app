```

     ___              __    _              ____                __
    /   |  __________/ /_  (_)   _____   / __ \___  ____ ____/ /__  _____
   / /| | / ___/ ___/ __ \/ / | / / _ \ / /_/ / _ \/ __ `/ __  / _ \/ ___/
  / ___ |/ /  / /__/ / / / /| |/ /  __// _, _/  __/ /_/ / /_/ /  __/ /
 /_/  |_/_/   \___/_/ /_/_/ |___/\___//_/ |_|\___/\__,_/\__,_/\___/_/

```



<p align="center">
  <em>Read the web. Without the web reading you back.</em>
</p>

<p align="center">
  <code>SwiftUI</code> &bull; <code>SwiftData</code> &bull; <code>iOS 17+</code> &bull; <code>WKWebView</code> &bull; <code>Readability.js</code>
</p>

---

```
    +-------------------------------------------+
    |  Safari                            [ ^ ]  |
    |                                           |
    |  "Wow, great article!"                    |
    |                                           |
    |        *taps share button*                |
    |                                           |
    |  +-------------------------------------+  |
    |  |  Archive Reader                     |  |
    |  |  [ Save to Archive ]                |  |
    |  +-------------------------------------+  |
    |                                           |
    |        *article saved forever*            |
    |                                           |
    +-------------------------------------------+
              |
              |  archivereader://archive?url=...
              v
    +-------------------------------------------+
    |  Archive Reader                    [*][R] |
    |-------------------------------------------|
    |                                           |
    |  # Article Title                          |
    |                                           |
    |  Clean, readable text with nice fonts     |
    |  and no popups, banners, or trackers.     |
    |                                           |
    |  Just words. On a page. Like the old      |
    |  days.                                    |
    |                                           |
    +-------------------------------------------+
```

## What Is This?

An iOS app that archives web articles via [archive.ph](https://archive.ph) and presents them in a clean, distraction-free reader.

**The problem:** You find a great article. You want to read it later. But later, it's behind a paywall, or buried in cookie banners, or just... gone.

**The solution:**

```
article + archive.ph + reader mode = peace of mind
```

## Features

```
 ___________
|           |
|  SHARE    |  -->  Share any URL from Safari (or any app)
|  SHEET    |       via the iOS share sheet
|___________|

 ___________
|           |
|  ARCHIVE  |  -->  Automatically archives via archive.ph
|  .PH      |       Checks for existing snapshots first
|___________|

 ___________
|           |
|  READER   |  -->  Mozilla Readability.js extracts the article
|  MODE     |       DOMPurify sanitizes the HTML
|___________|       Beautiful, themed reading experience

 ___________
|           |
|  THEMES   |  -->  Light / Dark / Sepia
|  & FONTS  |       5 font sizes (XS to XL)
|___________|       Settings persist across sessions
```

## Reader Mode Themes

```
+------------------+  +------------------+  +------------------+
|                  |  |                  |  |                  |
|   LIGHT          |  |   DARK           |  |   SEPIA          |
|                  |  |                  |  |                  |
|   Aa Aa Aa Aa    |  |   Aa Aa Aa Aa    |  |   Aa Aa Aa Aa    |
|                  |  |                  |  |                  |
|   Clean white    |  |   Easy on the    |  |   Warm paper     |
|   background     |  |   eyes at night  |  |   feeling        |
|                  |  |                  |  |                  |
|   #FFFFFF        |  |   #1A1A2E        |  |   #F4ECD8        |
|                  |  |                  |  |                  |
+------------------+  +------------------+  +------------------+
```

## Architecture

```
                    +-----------------------+
                    |    iOS Share Sheet     |
                    +-----------+-----------+
                                |
                                | URL
                                v
                    +-----------+-----------+
                    |   Share Extension     |
                    |                       |
                    |  - Extract URL        |
                    |  - Save to SwiftData  |
                    |  - Open main app      |
                    +-----------+-----------+
                                |
                       archivereader://
                                |
                                v
+-------------------------------+-------------------------------+
|                         Main App                              |
|                                                               |
|  +------------------+    +------------------+                 |
|  |  Article List    |--->|  Article Reader  |                 |
|  |                  |    |                  |                 |
|  |  @Query          |    |  WKWebView       |                 |
|  |  Searchable      |    |  archive.ph page |                 |
|  |  Swipe actions   |    |                  |                 |
|  +------------------+    +--------+---------+                 |
|                                   |                           |
|                          [Reader Mode Toggle]                 |
|                                   |                           |
|                                   v                           |
|                          +--------+---------+                 |
|                          |  Reader Mode     |                 |
|                          |                  |                 |
|                          |  Readability.js  |                 |
|                          |  DOMPurify       |                 |
|                          |  Custom HTML/CSS |                 |
|                          |  Theme engine    |                 |
|                          +------------------+                 |
|                                                               |
+---------------------------------------------------------------+
        |                                           |
        v                                           v
+-------+-------+                           +-------+-------+
|   SwiftData   |    <--- App Groups --->   |   SwiftData   |
| (shared store)|                           | (shared store)|
+---------------+                           +---------------+
   Main App                                  Share Extension
```

## Project Structure

```
ArchiveReader/
|
|--  ArchiveReader/            # Main app target
|   |--  App/                  # App entry point, deep linking
|   |--  Views/                # SwiftUI views
|   |--  ViewModels/           # Archive logic
|   |--  Resources/JavaScript/ # Readability.js, DOMPurify, bridge
|   '--  Assets.xcassets       # App icon, colors
|
|--  ArchiveReaderShareExtension/  # Share sheet extension
|   |--  ShareViewController.swift
|   '--  ShareExtensionView.swift
|
|--  Shared/                   # Shared between both targets
|   |--  Models/               # SwiftData models, settings
|   |--  Services/             # Archive service, persistence, reader
|   '--  Utilities/            # Constants, URL helpers
|
'--  project.yml               # XcodeGen project spec
```

## Getting Started

**Requirements:**
- Xcode 16+
- iOS 17.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

```bash
# Clone
git clone https://github.com/milesfitzgerald/archive.ph-iOS-app.git
cd archive.ph-iOS-app

# Generate Xcode project
xcodegen generate

# Open in Xcode
open ArchiveReader.xcodeproj

# Build & run on simulator or device
# (Select the "ArchiveReader" scheme)
```

## How It Works

```
1. You share a URL

   "Hey, save this for me"
           |
           v
2. Archive.ph preserves it

   archive.ph/?url=https://example.com/cool-article
           |
           v
3. You read it in peace

   No ads. No popups. No tracking.
   Just the article.
           |
           v
4. Reader mode (optional)

   Even cleaner. Your preferred
   theme and font size.
```

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| UI | SwiftUI | Declarative, modern, iOS 17+ |
| Persistence | SwiftData | Native, shared via App Groups |
| Web Rendering | WKWebView | Full browser engine for archive.ph pages |
| Article Extraction | Readability.js | Powers Firefox Reader View, battle-tested |
| HTML Sanitization | DOMPurify | Industry-standard XSS prevention |
| Project Generation | XcodeGen | `project.yml` > merge conflicts in `.pbxproj` |

## User Flows

```
                Share Flow                          Manual Flow
                ----------                          -----------

          +------------------+                +------------------+
          |  Any app with    |                |  Archive Reader  |
          |  share sheet     |                |  app             |
          +--------+---------+                +--------+---------+
                   |                                   |
            [Share] button                       [+] button
                   |                                   |
                   v                                   v
          +--------+---------+                +--------+---------+
          |  "Save to        |                |  Paste URL       |
          |   Archive"       |                |  tap "Archive"   |
          +--------+---------+                +--------+---------+
                   |                                   |
                   +---------------+-------------------+
                                   |
                                   v
                          +--------+---------+
                          |  Article saved   |
                          |  to SwiftData    |
                          +--------+---------+
                                   |
                                   v
                          +--------+---------+
                          |  archive.ph      |
                          |  loads in        |
                          |  WKWebView       |
                          +--------+---------+
                                   |
                              [optional]
                                   |
                                   v
                          +--------+---------+
                          |  Reader Mode     |
                          |  activated       |
                          +------------------+
```

---

```
    ,---.    ,---.  ,---.  .-. .-.  .-. .-. .-.  ,---.
    | .-.\  | .-'  / .-. ) | | | |  | | | \| |  | .-'
    | |-' ) | `-.  | |-|{  | `-| |  | | |  \| |  | `-.
    | |--'  | .-'  | | | | | .-. |  | | | |\  |  | .-'
    | |     |  `--.\ `-' / | | |)|  | | | | |)|  |  `--.
    /(      /( __.'.)---'  /(  (_)  `-' /(  (_)  /( __.'
   (__)    (__)   (_)     (__)        (__)      (__)

              the web, but make it readable
```

<p align="center">
  Made with SwiftUI, stubbornness, and a mass archive.ph tab addiction.
</p>
