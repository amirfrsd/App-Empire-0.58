import CryptoKit
import Foundation

enum ResourceIntegrityError: Error, Equatable {
    case missingResource(String)
    case hashMismatch(resource: String, expected: String, actual: String)
}

enum ResourceIntegrity {
    static let expectedHashes: [String: String] = [
        "economy.json": "4f7849227e70975d831909550fd2752ee4a20dbbe868569c750e06eb9908fd40",
        "products.json": "0a23d07a21f506caff5164ae080238278446c349ed33c968438715c4196b7fd3"
    ]

    static func verify(resourceAt url: URL, expectedHash: String) throws {
        let name = url.lastPathComponent
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ResourceIntegrityError.missingResource(name)
        }
        let digest = SHA256.hash(data: try Data(contentsOf: url))
        let actual = digest.map { String(format: "%02x", $0) }.joined()
        guard actual == expectedHash else {
            throw ResourceIntegrityError.hashMismatch(resource: name, expected: expectedHash, actual: actual)
        }
    }

    static func verifyBundledResources(in bundle: Bundle = .main) throws {
        for (name, hash) in expectedHashes {
            guard let url = bundle.url(forResource: name.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
                throw ResourceIntegrityError.missingResource(name)
            }
            try verify(resourceAt: url, expectedHash: hash)
        }
    }
}
