import Foundation

struct Wallpaper: Identifiable, Hashable {
    let id: String
    let originalURL: URL
    let thumbnailURL: URL
    let fullSizeURL: URL

    init?(urlString: String, transformer: ImgurURLTransformer) {
        guard let originalURL = URL(string: urlString) else { return nil }
        let baseOriginal = transformer.originalImageURL(for: originalURL)
        self.id = baseOriginal.absoluteString
        self.originalURL = baseOriginal
        self.thumbnailURL = transformer.thumbnailURL(for: baseOriginal)
        self.fullSizeURL = transformer.fullResolutionURL(for: baseOriginal)
    }
}
