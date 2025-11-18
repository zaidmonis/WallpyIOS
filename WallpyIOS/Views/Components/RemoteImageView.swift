import SwiftUI

struct RemoteImageView: View {
    let url: URL
    @StateObject private var loader: ImageLoader

    init(url: URL) {
        self.url = url
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        content
            .onAppear { loader.load() }
            .onDisappear { loader.cancel() }
    }

    @ViewBuilder
    private var content: some View {
        switch loader.state {
        case .idle, .loading:
            ZStack {
                Color(UIColor.secondarySystemBackground)
                ProgressView()
            }
        case .success(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case .failed:
            ZStack {
                Color(UIColor.secondarySystemBackground)
                Image(systemName: "wifi.exclamationmark")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@MainActor
private final class ImageLoader: ObservableObject {
    private let minImageByteSize = 10 * 1024 // Avoid caching tiny placeholder responses
    private let maxRetries = 3
    private enum LoadError: Error { case tooSmall, decodeFailed }
    enum State {
        case idle
        case loading
        case success(UIImage)
        case failed
    }

    @Published private(set) var state: State = .idle

    private let url: URL
    private let cache: ImageCache
    private var task: Task<Void, Never>?
    private var attempts = 0

    init(url: URL, cache: ImageCache = .shared) {
        self.url = url
        self.cache = cache
    }

    func load() {
        if case .loading = state { return }
        if case .success = state { return }

        if let cached = cache.image(for: url) {
            attempts = 0
            state = .success(cached)
            return
        }

        attempts += 1
        state = .loading
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard data.count >= minImageByteSize else {
                    throw LoadError.tooSmall
                }
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.attempts = 0
                        self.cache.store(image: image, for: self.url)
                        self.state = .success(image)
                    }
                } else {
                    throw LoadError.decodeFailed
                }
            } catch {
                if Task.isCancelled { return }
                if self.attempts < self.maxRetries {
                    await MainActor.run { self.state = .idle }
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                    await MainActor.run { self.load() }
                } else {
                    await MainActor.run { self.state = .failed }
                }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        if case .loading = state {
            state = .idle
        }
    }
}
