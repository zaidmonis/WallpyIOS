import SwiftUI

struct SettingsView: View {
    @Binding var hdThumbnailsEnabled: Bool
    let remoteVersion: Int?

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form {
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
