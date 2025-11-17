# WallpyIOS

WallpyIOS is a SwiftUI rewrite of the original Android Wallpy wallpaper application. It keeps the Firebase-backed catalogue, Imgur thumbnail conventions, and download flow while adopting modern iOS patterns such as Swift Concurrency, SwiftUI, and system sharing.

## Architecture

* **SwiftUI** for the UI layer and navigation.
* **Async/await + URLSession** to read the Realtime Database REST endpoints.
* **Property lists** (`FirebaseConfig.plist`) for lightweight configuration without hardcoding secrets.
* **Services + view models** to keep the code modular and testable.

```
WallpyIOS
├── App              # App entry point + dependency container
├── Config           # Firebase configuration + loaders
├── Models           # Data models that mirror Firebase data
├── Networking       # REST client for Firebase
├── Services         # Imgur URL helpers & Photo Library integration
├── ViewModels       # ObservableObject state containers
└── Views            # SwiftUI screens and components
```

## Firebase configuration

The app reads `WallpyIOS/WallpyIOS/Config/FirebaseConfig.plist` at runtime. Update the values with your own Firebase database URL and categories. If you are already using `google-services.json` in Android, you can find the corresponding Realtime Database URL in the Firebase console under **Project Settings → Service accounts**.

## Getting started

1. Open `WallpyIOS/WallpyIOS.xcodeproj` in Xcode 15 or newer.
2. Select the `WallpyIOS` scheme and an iOS 15+ device/simulator.
3. Update `FirebaseConfig.plist` with your database URL if needed.
4. Build & run.

## Feature parity highlights

* Category browsing identical to Android (`All`, `Anime`, `Girls`, etc.).
* Grid + detail preview with Imgur thumbnail/HD conversion.
* Manual update check hitting the `CurrentVersion` node.
* Save wallpaper to Photos and share via the system sheet (iOS does not allow setting the wallpaper programmatically, so users are guided to the Photos app instead).

## Creating a GitHub repository

This environment cannot push to GitHub directly. Once you pull these changes locally you can create a new repository by running:

```bash
git init
git add .
git commit -m "Add WallpyIOS"
gh repo create your-org/WallpyIOS --public --source=. --remote=origin --push
```

Replace `your-org` with the GitHub account or organization that should host the project.
