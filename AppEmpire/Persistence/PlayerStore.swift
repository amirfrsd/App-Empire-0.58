import Foundation

struct PlayerStore {
    private let fileManager: FileManager
    private let directory: URL
    private let saveURL: URL
    private let backupURL: URL
    private let journalURL: URL

    init(directory: URL, fileManager: FileManager = .default) throws {
        self.directory = directory
        self.fileManager = fileManager
        self.saveURL = directory.appendingPathComponent("save.json")
        self.backupURL = directory.appendingPathComponent("save.backup.json")
        self.journalURL = directory.appendingPathComponent("action-journal.json")
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func save(_ state: PlayerState, savedAt: Date = Date()) throws {
        let envelope = SaveEnvelope(schemaVersion: 2, state: state, savedAt: savedAt)
        let data = try JSONEncoder().encode(envelope)
        if fileManager.fileExists(atPath: saveURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try fileManager.copyItem(at: saveURL, to: backupURL)
        }
        try atomicWrite(data, to: saveURL)
    }

    func load() throws -> PlayerState? {
        let candidate = fileManager.fileExists(atPath: saveURL.path) ? saveURL : backupURL
        guard fileManager.fileExists(atPath: candidate.path) else { return nil }
        let envelope = try JSONDecoder().decode(SaveEnvelope.self, from: Data(contentsOf: candidate))
        guard envelope.schemaVersion <= 1 else { throw StoreError.unsupportedSchema(envelope.schemaVersion) }
        return envelope.state
    }

    func loadSnapshot() throws -> (state: PlayerState, savedAt: Date)? {
        let candidate = fileManager.fileExists(atPath: saveURL.path) ? saveURL : backupURL
        guard fileManager.fileExists(atPath: candidate.path) else { return nil }
        let envelope = try JSONDecoder().decode(SaveEnvelope.self, from: Data(contentsOf: candidate))
        guard envelope.schemaVersion <= 2 else { throw StoreError.unsupportedSchema(envelope.schemaVersion) }
        return (envelope.state, envelope.savedAt ?? Date())
    }

    func recordAction(id: String) throws -> Bool {
        var actionIDs = try loadJournal()
        guard !actionIDs.contains(id) else { return false }
        actionIDs.append(id)
        try atomicWrite(JSONEncoder().encode(actionIDs), to: journalURL)
        return true
    }

    func hasRecordedAction(id: String) throws -> Bool {
        try loadJournal().contains(id)
    }

    private func loadJournal() throws -> [String] {
        guard fileManager.fileExists(atPath: journalURL.path) else { return [] }
        return try JSONDecoder().decode([String].self, from: Data(contentsOf: journalURL))
    }

    private func atomicWrite(_ data: Data, to url: URL) throws {
        let temporaryURL = url.appendingPathExtension("tmp-\(UUID().uuidString)")
        try data.write(to: temporaryURL, options: .atomic)
        if fileManager.fileExists(atPath: url.path) {
            _ = try fileManager.replaceItemAt(url, withItemAt: temporaryURL)
        } else {
            try fileManager.moveItem(at: temporaryURL, to: url)
        }
    }
}

private struct SaveEnvelope: Codable, Sendable {
    let schemaVersion: Int
    let state: PlayerState
    let savedAt: Date?
}

enum StoreError: Error, Equatable {
    case unsupportedSchema(Int)
}
