import Foundation

struct ImgurURLTransformer {
    private let thumbnailSuffix: String
    private let preferredThumbnailSuffix: String
    private let fullSizeSuffix: String
    private let supportedExtensions = ["jpg", "jpeg", "png"]

    init(config: FirebaseConfig) {
        thumbnailSuffix = config.thumbnailQualitySuffix
        preferredThumbnailSuffix = config.preferredThumbnailSuffix
        fullSizeSuffix = config.fullSizeQualitySuffix
    }

    func thumbnailURL(for original: URL) -> URL {
        let base = stripKnownSuffixes(from: original)
        return apply(suffix: preferredThumbnailSuffix, toBase: base)
    }

    func fullResolutionURL(for original: URL) -> URL {
        let base = stripKnownSuffixes(from: original)
        return apply(suffix: fullSizeSuffix, toBase: base)
    }

    /// Removes any known quality suffix to get the original/origin URL stored in Firebase.
    func originalImageURL(for original: URL) -> URL {
        stripKnownSuffixes(from: original)
    }

    private func stripKnownSuffixes(from url: URL) -> URL {
        guard let comps = components(for: url) else { return url }
        let suffixes = [thumbnailSuffix, preferredThumbnailSuffix, fullSizeSuffix]
        for suffix in suffixes {
            if comps.name.hasSuffix(suffix) {
                let trimmed = String(comps.name.dropLast(suffix.count))
                return rebuildURL(directory: comps.directory, name: trimmed, ext: comps.ext) ?? url
            }
        }
        return url
    }

    private func apply(suffix: String, toBase base: URL) -> URL {
        guard let comps = components(for: base) else { return base }
        // Avoid double-appending if it already ends with the suffix in the name.
        let name = comps.name.hasSuffix(suffix) ? comps.name : "\(comps.name)\(suffix)"
        return rebuildURL(directory: comps.directory, name: name, ext: comps.ext) ?? base
    }

    private func components(for url: URL) -> (directory: URL, name: String, ext: String)? {
        let ext = url.pathExtension
        guard supportedExtensions.contains(ext.lowercased()) else { return nil }
        let directory = url.deletingLastPathComponent()
        let name = url.deletingPathExtension().lastPathComponent
        return (directory, name, ext)
    }

    private func rebuildURL(directory: URL, name: String, ext: String) -> URL? {
        directory.appendingPathComponent("\(name).\(ext)")
    }
}
