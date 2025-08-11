import XCTest
@testable import MarvelComicsStatusBar

final class MarvelClientTests: XCTestCase {
    func test_comics_decodes_success() async throws {
        let json = """
        { "data": { "results": [
            { "id": 1, "title": "A", "description": "d",
              "creators": { "items":[{"name":"Stan Lee"}] } }
        ] } }
        """.data(using: .utf8)!
        let url = URL(string: "https://stub.local")!

        URLProtocolStub.requestHandler = { _ in
            (HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, json)
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let client = MarvelClient(session: URLSession(configuration: config))

        let result = try await client.comics(limit: 1)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "A")
    }
}
