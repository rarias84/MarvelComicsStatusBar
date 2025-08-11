import Foundation
import CryptoKit

enum MarvelAPI {
    static let base = URL(string: "https://gateway.marvel.com")!

    static func comicsURL(limit: Int = 50, offset: Int = 0) throws -> URL {
        let ts = String(Int(Date().timeIntervalSince1970))
        let pub = Secrets.publicKey
        let priv = Secrets.privateKey
        let hash = md5Hex("\(ts)\(priv)\(pub)")

        var comps = URLComponents(url: base.appendingPathComponent("/v1/public/comics"),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "ts", value: ts),
            .init(name: "apikey", value: pub),
            .init(name: "hash", value: hash),
        ]
        return comps.url!
    }

    private static func md5Hex(_ s: String) -> String {
        Insecure.MD5.hash(data: Data(s.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

enum Secrets {
    static let publicKey = ProcessInfo.processInfo.environment["MARVEL_PUBLIC_KEY"] ?? ""
    static let privateKey = ProcessInfo.processInfo.environment["MARVEL_PRIVATE_KEY"] ?? ""
}
