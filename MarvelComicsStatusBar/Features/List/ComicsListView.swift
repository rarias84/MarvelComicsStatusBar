import SwiftUI

struct ComicsListView: View {
    @State private var didLoad = false
    @State private var path: [Comic] = []
    @State private var selectedComic: Comic?
    @StateObject var viewModel: ComicsListViewModel

    private var header: some View {
        Text("Marvel Comics")
            .font(.largeTitle)
            .bold()
            .padding(.top, 8)
            .padding(.horizontal)
            .padding(.bottom, 4)
    }

    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationStack(path: $path) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        list
                    }
                }
                .task {
                    guard !didLoad else {
                        return
                    }
                    didLoad = true
                    await viewModel.load()
                }
                .animation(.default, value: viewModel.isLoading)
                .onReceive(viewModel.$resetNavigationFlag) { shouldReset in
                    guard shouldReset else {
                        return
                    }
                    path.removeAll()
                    selectedComic = nil
                    viewModel.resetNavigationFlag = false
                }
                .navigationDestination(for: Comic.self) { comic in
                    ComicDetailView(viewModel: .init(comic: comic))
                }
            }
        } else {
            NavigationView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        list
                    }
                }
                .task {
                    guard !didLoad else {
                        return
                    }
                    didLoad = true
                    await viewModel.load()
                }
                .onReceive(viewModel.$resetNavigationFlag) { shouldReset in
                    guard shouldReset else {
                        return
                    }
                    path.removeAll()
                    selectedComic = nil
                    viewModel.resetNavigationFlag = false
                }

                placeholder
            }
        }
    }

    @ViewBuilder
    private var list: some View {
        List(selection: $selectedComic) {
            ForEach(viewModel.groups) { group in
                Section(header: Text(group.creator).font(.headline)) {
                    ForEach(group.comics) { comic in
                        row(for: comic)
                    }
                }
            }
            if let msg = viewModel.error {
                Text(msg)
                    .foregroundStyle(.red)
            }
        }
        .listStyle(.plain)
    }

    private var loadingView: some View {
        VStack {
            Spacer(minLength: 0)
            ProgressView()
                .controlSize(.large)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholder: some View {
        Text("Selecciona un cómic")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func row(for comic: Comic) -> some View {
        if #available(macOS 13.0, *) {
            NavigationLink(value: comic) {
                ComicRow(comic: comic)
            }
        } else {
            NavigationLink(
                destination: ComicDetailView(viewModel: .init(comic: comic)),
                tag: comic,
                selection: $selectedComic
            ) {
                ComicRow(comic: comic)
            }
        }
    }
}

private struct ComicRow: View {
    let comic: Comic
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: comic.thumbnailURL) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 48, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(comic.title)
                    .font(.headline)
                if let series = comic.seriesName {
                    Text("\(series) • #\(comic.issueNumber)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let price = comic.price {
                    Text("Precio: \(NumberFormatter.currency.string(from: price as NSNumber) ?? "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
