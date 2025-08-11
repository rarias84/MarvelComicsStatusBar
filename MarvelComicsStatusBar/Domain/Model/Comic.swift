import Foundation

struct Comic: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let issueNumber: Int
    let pageCount: Int
    let seriesName: String?
    let creators: [Creator]
    let characters: [String]
    let onsaleDate: Date?
    let price: Decimal?
    let detailURL: URL?
    let thumbnailURL: URL?
    let galleryURLs: [URL]

    struct Creator: Hashable {
        let name: String
        let role: String
    }
}

