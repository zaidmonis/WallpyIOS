import SwiftUI

struct WallpaperGridView: View {
    let wallpapers: [Wallpaper]
    let hdThumbnailsEnabled: Bool
    let onToggleFavorite: (Wallpaper) -> Void
    let isFavorite: (Wallpaper) -> Bool
    let onSelect: (Wallpaper) -> Void
    @State private var toastMessage: String?
    @State private var showToast = false
    @State private var toastTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { proxy in
            let columns = 3
            let spacing: CGFloat = 12
            let horizontalPadding: CGFloat = 16
            let totalSpacing = CGFloat(columns - 1) * spacing
            let availableWidth = proxy.size.width - (horizontalPadding * 2) - totalSpacing
            let itemWidth = floor(availableWidth / CGFloat(columns))
            let gridLayout = Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columns)

            ZStack(alignment: .top) {
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: spacing) {
                        ForEach(wallpapers) { wallpaper in
                            Button {
                                onSelect(wallpaper)
                            } label: {
                                WallpaperCard(
                                    wallpaper: wallpaper,
                                    hdThumbnailsEnabled: hdThumbnailsEnabled,
                                    width: itemWidth,
                                    isFavorite: isFavorite(wallpaper),
                                    onToggleFavorite: { onToggleFavorite(wallpaper) }
                                )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                LongPressGesture().onEnded { _ in
                                    presentToast(wallpaper.originalURL.absoluteString)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom)
                }

                if showToast, let toastMessage {
                    Text(toastMessage)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.black.opacity(0.8))
                        )
                        .padding(.top, 12)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func presentToast(_ text: String) {
        toastTask?.cancel()
        toastMessage = text
        showToast = true
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showToast = false
        }
    }
}
