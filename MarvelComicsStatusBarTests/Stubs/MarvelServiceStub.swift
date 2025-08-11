@testable import MarvelComicsStatusBar
import Foundation

struct MarvelServiceStub: MarvelService {
    let dtos: [ComicDTO]
    func comics(limit: Int) async throws -> [ComicDTO] { dtos }
}

struct MarvelServiceFailingStub: MarvelService {
    let errorToThrow: Error
    func comics(limit: Int) async throws -> [ComicDTO] { throw errorToThrow }
}

struct MarvelServiceDelayedStub: MarvelService {
    let dtos: [ComicDTO]
    let delay: TimeInterval
    func comics(limit: Int) async throws -> [ComicDTO] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return dtos
    }
}

struct MarvelServiceDelayedFailingStub: MarvelService {
    let errorToThrow: Error
    let delay: TimeInterval
    func comics(limit: Int) async throws -> [ComicDTO] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        throw errorToThrow
    }
}
