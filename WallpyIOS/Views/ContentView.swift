import SwiftUI

struct ContentView: View {
    @ObservedObject private var environment: AppEnvironment
    @StateObject private var viewModel: WallpaperGridViewModel
    @Binding private var hdThumbnailsEnabled: Bool
    @State private var isShowingSettings = false
    @State private var selectedWallpaper: Wallpaper?
    private let categories: [WallpaperCategory]

    init(environment: AppEnvironment, hdThumbnailsEnabled: Binding<Bool>) {
        _environment = ObservedObject(initialValue: environment)
        let categories = WallpaperCategory.buildList(from: environment.config)
        self.categories = categories
        let defaultCategory = categories.first ?? WallpaperCategory(id: "All")
        _viewModel = StateObject(wrappedValue: WallpaperGridViewModel(
            service: environment.firebaseService,
            transformer: environment.urlTransformer,
            defaultCategory: defaultCategory
        ))
        _hdThumbnailsEnabled = hdThumbnailsEnabled
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 8) {
                    CategoryPicker(categories: categories, selection: $viewModel.selectedCategory)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    content
                }
                .navigationTitle("Wallpy")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingSettings = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                .task(id: viewModel.selectedCategory.id) {
                    await viewModel.reload()
                }
                .task {
                    await environment.refreshRemoteVersion()
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView(hdThumbnailsEnabled: $hdThumbnailsEnabled, remoteVersion: environment.latestRemoteVersion)
                }
                .sheet(item: $selectedWallpaper) { wallpaper in
                    WallpaperDetailView(
                        wallpaper: wallpaper,
                        useHDPreview: hdThumbnailsEnabled,
                        photoLibraryService: environment.photoLibraryService
                    )
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading wallpapers…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            WallpaperGridView(
                wallpapers: viewModel.wallpapers,
                hdThumbnailsEnabled: hdThumbnailsEnabled,
                onSelect: { selectedWallpaper = $0 }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error):
            VStack(spacing: 12) {
                Text("Something went wrong")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await viewModel.reload() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
