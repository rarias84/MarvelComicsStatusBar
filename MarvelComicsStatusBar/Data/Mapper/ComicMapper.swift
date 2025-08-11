import Foundation

struct ComicMapper {
    static func map(_ dto: ComicDTO) -> Comic {
        let id: Int = dto.id
        let title: String = dto.title
        let description: String? = dto.description?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let issueNumber: Int = Int(dto.issueNumber ?? 0)
        let pageCount: Int = dto.pageCount ?? 0
        let seriesName: String? = dto.series?.name
        
        let creators: [Comic.Creator] = (dto.creators?.items ?? []).map {
            Comic.Creator(name: $0.name, role: $0.role ?? "")
        }
        let characters: [String] = (dto.characters?.items ?? []).map { $0.name }
        
        let onsaleDate: Date? = dto.dates?
            .first(where: { $0.type == "onsaleDate" })
            .flatMap { MarvelDateParser.parse($0.date) }
        
        let price: Decimal? = dto.prices?
            .first(where: { $0.type == "printPrice" && $0.price > 0 })
            .map { Decimal($0.price) }
        
        let detailURL: URL? = dto.urls?
            .first(where: { $0.type == "detail" })
            .flatMap { URL(string: $0.url) }
        
        let thumbnailURL: URL? = dto.thumbnail?.secureURL(variant: .portraitUncanny)
        let galleryURLs: [URL] = (dto.images ?? []).compactMap { $0.secureURL(variant: .landscapeIncredible) }
        
        return Comic(
            id: id,
            title: title,
            description: description,
            issueNumber: issueNumber,
            pageCount: pageCount,
            seriesName: seriesName,
            creators: creators,
            characters: characters,
            onsaleDate: onsaleDate,
            price: price,
            detailURL: detailURL,
            thumbnailURL: thumbnailURL,
            galleryURLs: galleryURLs
        )
    }
}

// MARK: - Local helpers (Data layer only)

private enum MarvelDateParser {
    static func parse(_ s: String) -> Date? {
        if let d = DateFormatter.marvelZ.date(from: s) {
            return d
        }
        return DateFormatter.marvelZZZZZ.date(from: s)
    }
}

private enum MarvelImageVariant: String {
    case portraitUncanny = "portrait_uncanny"
    case landscapeIncredible = "landscape_incredible"
}

private extension ThumbnailDTO {
    func secureURL(variant: MarvelImageVariant) -> URL? {
        guard !path.contains("image_not_available") else {
            return nil
        }

        var comps = URLComponents(string: path)
        comps?.scheme = "https"
        let base = comps?.url?.absoluteString ?? path
        let full = base + "/\(variant.rawValue)." + `extension`
        return URL(string: full)
    }
}
