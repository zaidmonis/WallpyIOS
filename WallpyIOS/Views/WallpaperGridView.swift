import SwiftUI

struct WallpaperGridView: View {
    let wallpapers: [Wallpaper]
    let hdThumbnailsEnabled: Bool
    let onToggleFavorite: (Wallpaper) -> Void
    let isFavorite: (Wallpaper) -> Bool
    let onSelect: (Wallpaper) -> Void

    var body: some View {
        GeometryReader { proxy in
            let columns = 3
            let spacing: CGFloat = 12
            let horizontalPadding: CGFloat = 16
            let totalSpacing = CGFloat(columns - 1) * spacing
            let availableWidth = proxy.size.width - (horizontalPadding * 2) - totalSpacing
            let itemWidth = floor(availableWidth / CGFloat(columns))
            let gridLayout = Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columns)
            let previewWidth = itemWidth * 2

            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: spacing) {
                    ForEach(wallpapers) { wallpaper in
                        if #available(iOS 16.0, *) {
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
                            .contextMenu {
                                Button {
                                    onSelect(wallpaper)
                                } label: {
                                    Label("View full size", systemImage: "arrow.up.left.and.arrow.down.right")
                                }
                            } preview: {
                                RemoteImageView(url: wallpaper.fullSizeURL)
                                    .frame(width: previewWidth, height: previewWidth * 16 / 9)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom)
            }
        }
    }
}
