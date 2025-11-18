import Foundation

@MainActor
final class WallpaperGridViewModel: ObservableObject {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(Error)
    }

    @Published private(set) var wallpapers: [Wallpaper] = []
    @Published private(set) var state: LoadState = .idle
    @Published var selectedCategory: WallpaperCategory

    private let service: FirebaseService
    private let transformer: ImgurURLTransformer
    private let favoritesStore: FavoritesStore

    init(service: FirebaseService, transformer: ImgurURLTransformer, favoritesStore: FavoritesStore, defaultCategory: WallpaperCategory) {
        self.service = service
        self.transformer = transformer
        self.favoritesStore = favoritesStore
        self.selectedCategory = defaultCategory
    }

    func reload() async {
        // Handle local favourites without hitting the network
        if selectedCategory.id == "❤️Favourites" {
            wallpapers = favoritesStore.favorites.compactMap { Wallpaper(urlString: $0, transformer: transformer) }
            state = .loaded
            return
        }

        state = .loading
        do {
            let items = try await service.fetchWallpapers(category: selectedCategory.id, transformer: transformer)
            wallpapers = items
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }

    func toggleFavorite(_ wallpaper: Wallpaper) {
        favoritesStore.toggle(id: wallpaper.originalURL.absoluteString)
        if selectedCategory.id == "❤️Favourites" {
            Task { await reload() }
        }
        objectWillChange.send()
    }

    func isFavorite(_ wallpaper: Wallpaper) -> Bool {
        favoritesStore.isFavorite(id: wallpaper.originalURL.absoluteString)
    }
}
