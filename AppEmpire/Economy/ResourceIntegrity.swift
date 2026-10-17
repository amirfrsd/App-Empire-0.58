import CryptoKit
import Foundation

enum ResourceIntegrityError: Error, Equatable {
    case missingResource(String)
    case hashMismatch(resource: String, expected: String, actual: String)
}

enum ResourceIntegrity {
    static let expectedHashes: [String: String] = [
        "economy.json": "bb47ecab38b6fd6ae0991afe5a165dbaadfc617949527cfce9a64d3ff934250f",
        "products.json": "8ef9d966f488e13d7747fe4bbfb085c8f3788d10d7b625e1ca48f76c6126d400"
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
