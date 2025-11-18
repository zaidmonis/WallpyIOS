import Foundation

/// Global container that wires together configuration, services, and shared state objects.
@MainActor
final class AppEnvironment: ObservableObject {
    let config: FirebaseConfig
    let firebaseService: FirebaseService
    let photoLibraryService: PhotoLibraryService
    let urlTransformer: ImgurURLTransformer

    @Published var latestRemoteVersion: Int?
    @Published var categories: [WallpaperCategory] = []

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
        categories = WallpaperCategory.buildList(from: config)
    }

    func refreshRemoteVersion() async {
        do {
            latestRemoteVersion = try await firebaseService.fetchRemoteAppVersion()
        } catch {
            latestRemoteVersion = nil
        }
    }

    func refreshCategories() async {
        do {
            let names = try await firebaseService.fetchCategories()
            categories = names.map { WallpaperCategory(id: $0) }
        } catch {
            // Keep existing categories on failure.
        }
    }
}
