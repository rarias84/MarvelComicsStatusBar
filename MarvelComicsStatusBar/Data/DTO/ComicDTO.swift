import Foundation

struct ComicDTO: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String?

    let issueNumber: Double?
    let pageCount: Int?

    let series: SeriesDTO?
    let dates: [ComicDateDTO]?
    let prices: [ComicPriceDTO]?
    let thumbnail: ThumbnailDTO?
    let images: [ThumbnailDTO]?
    let urls: [URLEntryDTO]?

    let creators: CreatorsDTO?
    let characters: CharactersDTO?
}

struct SeriesDTO: Decodable {
    let name: String?
}

struct ComicDateDTO: Decodable {
    let type: String
    let date: String
}

struct ComicPriceDTO: Decodable {
    let type: String
    let price: Double
}

struct ThumbnailDTO: Decodable {
    let path: String
    let `extension`: String
}

struct URLEntryDTO: Decodable {
    let type: String
    let url: String
}

struct CreatorsDTO: Decodable {
    let items: [CreatorItemDTO]
}

struct CreatorItemDTO: Decodable {
    let name: String
    let role: String?
}

struct CharactersDTO: Decodable {
    let items: [CharacterItemDTO]
}

struct CharacterItemDTO: Decodable {
    let name: String
}
