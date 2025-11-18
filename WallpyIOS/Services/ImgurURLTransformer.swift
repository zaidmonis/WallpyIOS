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
        apply(suffix: preferredThumbnailSuffix, to: original)
    }

    func fullResolutionURL(for original: URL) -> URL {
        apply(suffix: fullSizeSuffix, to: original)
    }

    /// Return the given URL unchanged.
    func originalImageURL(for original: URL) -> URL {
        original
    }

    private func apply(suffix: String, to original: URL) -> URL {
        guard let comps = components(for: original) else { return original }
        let nameWithSuffix = comps.name + suffix
        return rebuildURL(directory: comps.directory, name: nameWithSuffix, ext: comps.ext) ?? original
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
