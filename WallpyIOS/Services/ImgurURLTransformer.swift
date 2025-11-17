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
        var absolute = url.absoluteString
        let suffixes = [thumbnailSuffix, preferredThumbnailSuffix, fullSizeSuffix]
        for ext in supportedExtensions {
            for suffix in suffixes {
                let token = "\(suffix).\(ext)"
                if absolute.contains(token) {
                    absolute = absolute.replacingOccurrences(of: token, with: ".\(ext)")
                }
            }
        }
        return URL(string: absolute) ?? url
    }

    private func apply(suffix: String, toBase base: URL) -> URL {
        var absolute = base.absoluteString
        for ext in supportedExtensions {
            let token = ".\(ext)"
            if absolute.hasSuffix(token) {
                absolute = absolute.replacingOccurrences(of: token, with: "\(suffix)\(token)")
                break
            }
        }
        return URL(string: absolute) ?? base
    }
}
