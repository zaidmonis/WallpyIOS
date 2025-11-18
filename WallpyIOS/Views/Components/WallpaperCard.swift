import SwiftUI

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let hdThumbnailsEnabled: Bool
    let width: CGFloat
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    private var height: CGFloat { width * 16 / 9 }
    @State private var animateHeart = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RemoteImageView(url: hdThumbnailsEnabled ? wallpaper.fullSizeURL : wallpaper.thumbnailURL)
                .aspectRatio(9.0 / 16.0, contentMode: .fill)
                .frame(width: width, height: height, alignment: .center)
                .clipped()
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            Button(action: {
                onToggleFavorite()
                triggerBounce()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .white)
                    .padding(10)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
                    .scaleEffect(animateHeart ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateHeart)
            }
            .padding(8)
            .onChange(of: isFavorite) { newValue in
                if newValue {
                    triggerBounce()
                }
            }
        }
    }

    private func triggerBounce() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            animateHeart = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animateHeart = false
        }
    }
}
