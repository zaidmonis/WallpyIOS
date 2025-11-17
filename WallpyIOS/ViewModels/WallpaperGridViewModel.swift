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

    init(service: FirebaseService, transformer: ImgurURLTransformer, defaultCategory: WallpaperCategory) {
        self.service = service
        self.transformer = transformer
        self.selectedCategory = defaultCategory
    }

    func reload() async {
        state = .loading
        do {
            let items = try await service.fetchWallpapers(category: selectedCategory.id, transformer: transformer)
            wallpapers = items
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
