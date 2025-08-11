import SwiftUI

struct ComicDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ComicDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    metaRow
                    coverImage
                    descriptionSection
                    creatorsSection
                    charactersSection
                    externalLink
                    gallerySection
                    attributionSection
                }
                .padding()
            }
        }
        .navigationTitle("Marvel Comics")
    }

    @ViewBuilder
    private var topBar: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Label("Atrás", systemImage: "chevron.left")
                    .font(.headline)
            }
            .buttonStyle(.borderless)
            .contentShape(Rectangle())
            .keyboardShortcut(.escape, modifiers: [])
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var metaRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.comic.title)
                .font(.title)
                .bold()
            if let series = viewModel.comic.seriesName {
                Text("\(series) • #\(viewModel.comic.issueNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 16) {
                if viewModel.comic.pageCount > 0 {
                    Label("\(viewModel.comic.pageCount) págs", systemImage: "doc.plaintext")
                }
                if let date = viewModel.onsaleText {
                    Label(date, systemImage: "calendar")
                }
                if let price = viewModel.priceText {
                    Label(price, systemImage: "tag")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var coverImage: some View {
        if let url = viewModel.comic.thumbnailURL {
            AsyncImage(url: url) { img in
                img
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if let desc = viewModel.comic.description, !desc.isEmpty {
            Text(desc)
                .font(.body)
                .lineLimit(4)
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var creatorsSection: some View {
        if !viewModel.comic.creators.isEmpty {
            Text("Creadores")
                .font(.headline)
            WrapLayout {
                ForEach(viewModel.comic.creators, id: \.self) { comic in
                    Text("\(comic.name) – \(comic.role)")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
            }
        }
    }

    @ViewBuilder
    private var charactersSection: some View {
        if !viewModel.comic.characters.isEmpty {
            Text("Personajes")
                .font(.headline)
            WrapLayout {
                ForEach(viewModel.comic.characters, id: \.self) { name in
                    Text(name)
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
            }
        }
    }

    @ViewBuilder
    private var externalLink: some View {
        if let url = viewModel.comic.detailURL {
            Link(destination: url) {
                Label("Ver en Marvel", systemImage: "link")
            }
            .buttonStyle(.link)
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var gallerySection: some View {
        if !viewModel.comic.galleryURLs.isEmpty {
            Text("Galería").font(.headline).padding(.top, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.comic.galleryURLs, id: \.self) { url in
                        AsyncImage(url: url) { img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(width: 220, height: 124)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var attributionSection: some View {
        if let attribution = viewModel.attributionText {
            Text(attribution)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }
}

struct WrapLayout<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
            content
        }
    }
}
