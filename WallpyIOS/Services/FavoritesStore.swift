import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favorites: Set<String>

    private let storageKey = "favorites.wallpy"

    init() {
        if let data = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            favorites = Set(data)
        } else {
            favorites = []
        }
    }

    func toggle(id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        persist()
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }

    private func persist() {
        UserDefaults.standard.set(Array(favorites), forKey: storageKey)
    }
}
