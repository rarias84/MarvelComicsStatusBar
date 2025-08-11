import Foundation

protocol MarvelService {
    func comics(limit: Int) async throws -> [ComicDTO]
}

actor MarvelClient: MarvelService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    static func live() -> MarvelClient {
        MarvelClient()
    }

    struct ComicsEnvelope: Decodable {
        struct DataBlock: Decodable {
            let results: [ComicDTO]
        }
        let data: DataBlock
    }

    func comics(limit: Int = 50) async throws -> [ComicDTO] {
        let url = try MarvelAPI.comicsURL(limit: limit)
        let (data, resp) = try await session.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ComicsEnvelope.self, from: data).data.results
    }
}
