import Foundation

/// Global container that wires together configuration, services, and shared state objects.
@MainActor
final class AppEnvironment: ObservableObject {
    let config: FirebaseConfig
    let firebaseService: FirebaseService
    let photoLibraryService: PhotoLibraryService
    let urlTransformer: ImgurURLTransformer
    let favoritesStore: FavoritesStore

    @Published var latestRemoteVersion: Int?
    @Published var categories: [WallpaperCategory] = []
    @Published var isOfflineMode = false

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
        favoritesStore = FavoritesStore()
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
            var mapped = names.sorted().map { WallpaperCategory(id: $0) }
            // Insert local favorites category at the top.
            mapped.insert(WallpaperCategory(id: "❤️Favourites"), at: 0)
            categories = mapped
            isOfflineMode = false
        } catch {
            // No network: if we have favourites, show only that local category.
            if !favoritesStore.favorites.isEmpty {
                categories = [WallpaperCategory(id: "❤️Favourites")]
                isOfflineMode = true
            } else if categories.isEmpty {
                var mapped = WallpaperCategory.buildList(from: config).sorted { $0.id < $1.id }
                mapped.insert(WallpaperCategory(id: "❤️Favourites"), at: 0)
                categories = mapped
                isOfflineMode = true
            }
        }
    }
}
