# Wallpy iOS — My 2020 Android app, rebuilt for iPhone

This is the iOS clone of **my own** Wallpy Android app (originally released in 2020). Same catalogue and backend, but rewritten with SwiftUI and Swift Concurrency.

## What it is
- A wallpaper browser fed by Firebase Realtime Database JSON.
- Imgur hosts the actual images; Firebase stores Imgur links.
- Grid is uniform 3-column, 9:16 tiles; detail view shows full quality; saving/sharing uses the original image.

## Data & infrastructure
- **Firebase RTDB:** Holds plain JSON lists per category (`All.json`, `Anime.json`, etc.) plus a `CurrentVersion` node for update checks.
- **Imgur hosting:** Links in Firebase already include quality suffixes (e.g., `...m.jpg`, `...l.jpg`, `...h.jpg`). The app strips suffixes to recover the base/original, then reapplies controlled suffixes when needed.
  - Grid thumbnails: uses a preferred thumbnail suffix (`l` by default).
  - Detail, save, share: always fetch the suffix-free original URL.
- **Config:** `WallpyIOS/WallpyIOS/Config/FirebaseConfig.plist` defines the Firebase database URL, categories, and suffix choices.
- **Networking:** Plain REST via `URLSession` + async/await (no Firebase SDK).
- **Caching:** Lightweight in-memory image cache so images stay visible after fast scrolling.

## Project map
```
WallpyIOS
├── App              # App entry + dependency container
├── Config           # Firebase configuration and loader
├── Models           # Wallpaper model with URL shaping
├── Networking       # Firebase REST client
├── Services         # Imgur URL transformer, cache, Photo Library
├── ViewModels       # ObservableObject state
└── Views            # SwiftUI screens/components (grid, detail, settings)
```

## Notes
- iOS cannot set the system wallpaper programmatically; users save to Photos and apply manually.
- Share uses the actual image (not just the URL).
- If you add auth or change Firebase paths, update `FirebaseConfig.plist` accordingly.

## Attribution
Wallpy iOS is a faithful Apple-native clone of my own Wallpy Android app (2020) — same creator, same pipeline, new platform.
