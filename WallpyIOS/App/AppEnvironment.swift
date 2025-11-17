import Foundation

/// Global container that wires together configuration, services, and shared state objects.
@MainActor
final class AppEnvironment: ObservableObject {
    let config: FirebaseConfig
    let firebaseService: FirebaseService
    let photoLibraryService: PhotoLibraryService
    let urlTransformer: ImgurURLTransformer

    @Published var latestRemoteVersion: Int?

    init() {
        let loader = FirebaseConfigLoader()
        do {
            config = try loader.load()
            #if DEBUG
            print("Loaded Firebase config databaseURL=\(config.databaseURL)")
            #endif
        } catch {
            config = FirebaseConfig.placeholder
            print("FirebaseConfig load failed: \(error.localizedDescription). Using placeholder \(config.databaseURL)")
        }

        firebaseService = FirebaseService(config: config)
        photoLibraryService = PhotoLibraryService()
        urlTransformer = ImgurURLTransformer(config: config)
    }

    func refreshRemoteVersion() async {
        do {
            latestRemoteVersion = try await firebaseService.fetchRemoteAppVersion()
        } catch {
            latestRemoteVersion = nil
        }
    }
}
