import Foundation

struct WallpaperCategory: Identifiable, Hashable {
    let id: String
    var name: String { id }

    static func buildList(from config: FirebaseConfig) -> [WallpaperCategory] {
        config.categories.map { WallpaperCategory(id: $0) }
    }
}
