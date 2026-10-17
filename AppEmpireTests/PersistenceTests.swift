import XCTest
@testable import AppEmpire

final class PersistenceTests: XCTestCase {
    func testSaveAndLoadRoundTripPreservesPlayerState() throws {
        let directory = try temporaryDirectory()
        let store = try PlayerStore(directory: directory)
        let state = PlayerState.starter()

        try store.save(state)

        XCTAssertEqual(try store.load(), state)
    }

    func testActionJournalIsIdempotent() throws {
        let directory = try temporaryDirectory()
        let store = try PlayerStore(directory: directory)

        XCTAssertTrue(try store.recordAction(id: "tap-1"))
        XCTAssertFalse(try store.recordAction(id: "tap-1"))
        XCTAssertTrue(try store.hasRecordedAction(id: "tap-1"))
    }

    func testBackupRestoresWhenPrimarySaveIsMissing() throws {
        let directory = try temporaryDirectory()
        let store = try PlayerStore(directory: directory)
        let first = PlayerState.starter()
        var second = first
        second.cashCents = 12_345

        try store.save(first)
        try store.save(second)
        try FileManager.default.removeItem(at: directory.appendingPathComponent("save.json"))

        XCTAssertEqual(try store.load(), first)
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppEmpireTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }
}
