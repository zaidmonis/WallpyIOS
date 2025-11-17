import SwiftUI

struct CategoryPicker: View {
    let categories: [WallpaperCategory]
    @Binding var selection: WallpaperCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    Button {
                        selection = category
                    } label: {
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(selection == category ? Color.accentColor.opacity(0.2) : Color.clear)
                            .foregroundColor(selection == category ? .accentColor : .primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selection == category ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
