import SwiftUI
import UIKit

struct WallpaperDetailView: View {
    let wallpaper: Wallpaper
    let useHDPreview: Bool
    let photoLibraryService: PhotoLibraryService
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var isShowingError = false
    @State private var isShowingShareError = false
    @State private var shareError: String?
    @State private var isShowingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var isPreparingShare = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    // Always preview the original; save should also use original.
                    RemoteImageView(url: wallpaper.originalURL)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(24)
                        .padding()
                    Spacer()
                    actions
                }
                .navigationTitle("Preview")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
                .alert("Unable to save", isPresented: $isShowingError, actions: {
                    Button("OK", role: .cancel) {
                        isShowingError = false
                    }
                }, message: {
                    Text(saveError ?? "Unknown error")
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Task { await saveToPhotos() }
            } label: {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSaving)

            Button {
                Task { await prepareShareImage() }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isPreparingShare)
            .sheet(isPresented: $isShowingShareSheet) {
                if let image = shareImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
        .padding([.horizontal, .bottom])
        .alert("Unable to share", isPresented: $isShowingShareError, actions: {
            Button("OK", role: .cancel) {
                isShowingShareError = false
            }
        }, message: {
            Text(shareError ?? "Unknown error")
        })
    }

    private func saveToPhotos() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            // Always save the original full-size URL (no quality suffix).
            let (data, _) = try await URLSession.shared.data(from: wallpaper.originalURL)
            try await photoLibraryService.saveImage(data: data)
        } catch {
            saveError = error.localizedDescription
            isShowingError = true
        }
    }

    private func prepareShareImage() async {
        guard !isPreparingShare else { return }
        isPreparingShare = true
        defer { isPreparingShare = false }

        do {
            // Always share the original-quality image.
            let (data, _) = try await URLSession.shared.data(from: wallpaper.originalURL)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            shareImage = image
            isShowingShareSheet = true
        } catch {
            shareError = error.localizedDescription
            isShowingShareError = true
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
