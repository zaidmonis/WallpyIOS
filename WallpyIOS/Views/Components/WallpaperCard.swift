import SwiftUI

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let hdThumbnailsEnabled: Bool
    let width: CGFloat
    private var height: CGFloat { width * 16 / 9 }

    var body: some View {
        RemoteImageView(url: hdThumbnailsEnabled ? wallpaper.fullSizeURL : wallpaper.thumbnailURL)
            .aspectRatio(9.0 / 16.0, contentMode: .fill)
            .frame(width: width, height: height, alignment: .center)
            .clipped()
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}
