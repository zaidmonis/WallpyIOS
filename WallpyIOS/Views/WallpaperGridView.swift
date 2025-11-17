import SwiftUI

struct WallpaperGridView: View {
    let wallpapers: [Wallpaper]
    let hdThumbnailsEnabled: Bool
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

            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: spacing) {
                    ForEach(wallpapers) { wallpaper in
                        Button {
                            onSelect(wallpaper)
                        } label: {
                            WallpaperCard(
                                wallpaper: wallpaper,
                                hdThumbnailsEnabled: hdThumbnailsEnabled,
                                width: itemWidth
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom)
            }
        }
    }
}
