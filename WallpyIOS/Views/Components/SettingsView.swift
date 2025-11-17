import SwiftUI

struct SettingsView: View {
    @Binding var hdThumbnailsEnabled: Bool
    let remoteVersion: Int?
    private let logoSize: CGFloat = 120

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form {
                    VStack(spacing: 12) {
                        Spacer(minLength: 8)
                        Image("WallpyLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoSize, height: logoSize)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                        Text("Wallpy iOS")
                            .font(.title3.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                    Section(header: Text("Display")) {
                        Toggle("Use HD thumbnails", isOn: $hdThumbnailsEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        Text("Enabling this option loads the higher resolution Imgur variant for the grid thumbnails.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Section(header: Text("Updates")) {
                        if let remoteVersion {
                            Text("Latest version in Firebase: \(remoteVersion)")
                        } else {
                            Text("Unable to check for updates right now")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @Environment(\.dismiss) private var dismiss
}
