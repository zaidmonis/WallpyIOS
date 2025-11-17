import SwiftUI

@main
struct WallpyIOSApp: App {
    @StateObject private var environment = AppEnvironment()
    @AppStorage("hdThumbnailsEnabled") private var hdThumbnailsEnabled: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView(environment: environment, hdThumbnailsEnabled: $hdThumbnailsEnabled)
                .environmentObject(environment)
        }
    }
}
