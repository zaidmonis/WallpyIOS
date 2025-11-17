import Foundation

struct FirebaseService {
    private let config: FirebaseConfig
    private let session: URLSession

    /// Surface clearer server errors instead of the vague URLError -1011.
    private enum APIError: LocalizedError {
        case badStatus(url: URL, code: Int, body: String?)
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case let .badStatus(url, code, body):
                if let body, !body.isEmpty {
                    return "Server returned \(code) for \(url): \(body.prefix(200))"
                }
                return "Server returned \(code) for \(url)"
            case .invalidResponse:
                return "Invalid server response"
            }
        }
    }

    init(config: FirebaseConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func fetchWallpapers(category: String, transformer: ImgurURLTransformer) async throws -> [Wallpaper] {
        let url = config.databaseURL.appendingPathComponent("\(category).json")
        print("FirebaseService request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)
        try validate(requestURL: url, response: response, data: data)
        let urlStrings = try decodeURLStrings(from: data)
        return urlStrings.compactMap { Wallpaper(urlString: $0, transformer: transformer) }
    }

    func fetchRemoteAppVersion() async throws -> Int {
        let url = config.databaseURL.appendingPathComponent("\(config.versionNode).json")
        print("FirebaseService request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)
        try validate(requestURL: url, response: response, data: data)
        if let values = try? JSONDecoder().decode([Int].self, from: data), let version = values.first {
            return version
        }
        if let value = try? JSONDecoder().decode(Int.self, from: data) {
            return value
        }
        if let dict = try? JSONDecoder().decode([String: Int].self, from: data), let version = dict.values.sorted().first {
            return version
        }
        throw URLError(.cannotParseResponse)
    }

    private func decodeURLStrings(from data: Data) throws -> [String] {
        if let array = try? JSONDecoder().decode([String].self, from: data) {
            return array
        }
        if let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            return dict
                .sorted { lhs, rhs in lhs.key < rhs.key }
                .map { $0.value }
        }
        if let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return object.values.compactMap { $0 as? String }
        }
        throw URLError(.cannotParseResponse)
    }

    private func validate(requestURL: URL, response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            let body = String(data: data, encoding: .utf8)
            print("FirebaseService request failed url=\(requestURL.absoluteString) status=\(httpResponse.statusCode) body=\(body ?? "<none>")")
            throw APIError.badStatus(url: requestURL, code: httpResponse.statusCode, body: body)
        }
    }
}
