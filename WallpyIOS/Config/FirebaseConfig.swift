import Foundation

struct FirebaseConfig: Decodable {
    let databaseURL: URL
    let categories: [String]
    let thumbnailQualitySuffix: String
    let preferredThumbnailSuffix: String
    let fullSizeQualitySuffix: String
    let versionNode: String

    static var placeholder: FirebaseConfig {
        FirebaseConfig(
            databaseURL: URL(string: "https://example.firebaseio.com")!,
            categories: ["All"],
            thumbnailQualitySuffix: "m",
            preferredThumbnailSuffix: "l",
            fullSizeQualitySuffix: "h",
            versionNode: "CurrentVersion"
        )
    }
}

struct FirebaseConfigLoader {
    enum LoaderError: LocalizedError {
        case fileMissing
        case decodeFailed(Error)

        var errorDescription: String? {
            switch self {
            case .fileMissing:
                return "FirebaseConfig.plist not found in app bundle."
            case let .decodeFailed(error):
                return "Failed to decode FirebaseConfig.plist: \(error.localizedDescription)"
            }
        }
    }

    func load() throws -> FirebaseConfig {
        let bundle = Bundle.main

        // Primary lookup
        var candidateURL = bundle.url(forResource: "FirebaseConfig", withExtension: "plist")

        // Fallback: scan any subdirectory in case Xcode preserved folder structure.
        if candidateURL == nil {
            let matches = bundle.urls(forResourcesWithExtension: "plist", subdirectory: nil)?
                .first { $0.lastPathComponent == "FirebaseConfig.plist" }
            candidateURL = matches
        }

        guard let url = candidateURL else {
            throw LoaderError.fileMissing
        }

#if DEBUG
        print("FirebaseConfig.plist found at: \(url)")
#endif

        let data = try Data(contentsOf: url)
        do {
            return try PropertyListDecoder().decode(FirebaseConfig.self, from: data)
        } catch {
            // Attempt a manual decode to surface what we actually received.
            if let raw = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
               let manual = FirebaseConfig.from(dictionary: raw) {
                print("FirebaseConfig decoded via manual fallback: \(manual.databaseURL)")
                return manual
            }
            throw LoaderError.decodeFailed(error)
        }
    }
}

private extension FirebaseConfig {
    static func from(dictionary: [String: Any]) -> FirebaseConfig? {
        guard let urlString = dictionary["databaseURL"] as? String,
              let url = URL(string: urlString) else { return nil }

        let categories = dictionary["categories"] as? [String] ?? ["All"]
        let thumb = dictionary["thumbnailQualitySuffix"] as? String ?? "m"
        let preferredThumb = dictionary["preferredThumbnailSuffix"] as? String ?? thumb
        let full = dictionary["fullSizeQualitySuffix"] as? String ?? "h"
        let versionNode = dictionary["versionNode"] as? String ?? "CurrentVersion"

        return FirebaseConfig(
            databaseURL: url,
            categories: categories,
            thumbnailQualitySuffix: thumb,
            preferredThumbnailSuffix: preferredThumb,
            fullSizeQualitySuffix: full,
            versionNode: versionNode
        )
    }
}
