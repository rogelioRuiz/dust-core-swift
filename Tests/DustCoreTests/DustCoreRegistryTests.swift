import XCTest
@testable import DustCore

final class DustCoreRegistryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DustCoreRegistry.shared.resetForTesting()
    }

    // MARK: - M2-T1: Resolve unregistered throws serviceNotRegistered

    func testResolveUnregisteredVectorStoreThrows() {
        XCTAssertThrowsError(try DustCoreRegistry.shared.resolveVectorStore()) { error in
            XCTAssertEqual(error as? DustCoreError, .serviceNotRegistered(serviceName: "VectorStore"))
        }
    }

    func testResolveUnregisteredModelServerThrows() {
        XCTAssertThrowsError(try DustCoreRegistry.shared.resolveModelServer()) { error in
            XCTAssertEqual(error as? DustCoreError, .serviceNotRegistered(serviceName: "ModelServer"))
        }
    }

    func testResolveUnregisteredEmbeddingServiceThrows() {
        XCTAssertThrowsError(try DustCoreRegistry.shared.resolveEmbeddingService()) { error in
            XCTAssertEqual(error as? DustCoreError, .serviceNotRegistered(serviceName: "EmbeddingService"))
        }
    }

    // MARK: - M2-T2: Register and resolve round-trip (identity equality)

    func testRegisterResolveVectorStoreIdentity() throws {
        let mock = MockVectorStore()
        DustCoreRegistry.shared.register(vectorStore: mock)
        let resolved = try DustCoreRegistry.shared.resolveVectorStore()
        XCTAssertTrue(resolved === mock)
    }

    func testRegisterResolveModelServerIdentity() throws {
        let mock = MockModelServer()
        DustCoreRegistry.shared.register(modelServer: mock)
        let resolved = try DustCoreRegistry.shared.resolveModelServer()
        XCTAssertTrue(resolved === mock)
    }

    func testRegisterResolveEmbeddingServiceIdentity() throws {
        let mock = MockEmbeddingService()
        DustCoreRegistry.shared.register(embeddingService: mock)
        let resolved = try DustCoreRegistry.shared.resolveEmbeddingService()
        XCTAssertTrue(resolved === mock)
    }

    // MARK: - M2-T3: Re-registration replaces previous (last-write-wins)

    func testReRegisterVectorStoreLastWriteWins() throws {
        let first = MockVectorStore()
        let second = MockVectorStore()
        DustCoreRegistry.shared.register(vectorStore: first)
        DustCoreRegistry.shared.register(vectorStore: second)
        let resolved = try DustCoreRegistry.shared.resolveVectorStore()
        XCTAssertTrue(resolved === second)
        XCTAssertFalse(resolved === first)
    }

    func testReRegisterModelServerLastWriteWins() throws {
        let first = MockModelServer()
        let second = MockModelServer()
        DustCoreRegistry.shared.register(modelServer: first)
        DustCoreRegistry.shared.register(modelServer: second)
        let resolved = try DustCoreRegistry.shared.resolveModelServer()
        XCTAssertTrue(resolved === second)
    }

    func testReRegisterEmbeddingServiceLastWriteWins() throws {
        let first = MockEmbeddingService()
        let second = MockEmbeddingService()
        DustCoreRegistry.shared.register(embeddingService: first)
        DustCoreRegistry.shared.register(embeddingService: second)
        let resolved = try DustCoreRegistry.shared.resolveEmbeddingService()
        XCTAssertTrue(resolved === second)
    }

    // MARK: - M2-T4: Thread-safe concurrent registration (TSan)

    func testConcurrentRegisterNoDataRace() {
        let expectation = expectation(description: "concurrent register")
        expectation.expectedFulfillmentCount = 100

        for _ in 0..<100 {
            DispatchQueue.global().async {
                let mock = MockVectorStore()
                DustCoreRegistry.shared.register(vectorStore: mock)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNoThrow(try DustCoreRegistry.shared.resolveVectorStore())
    }

    // MARK: - M2-T5: Thread-safe concurrent read

    func testConcurrentResolveReturnsSameInstance() throws {
        let mock = MockVectorStore()
        DustCoreRegistry.shared.register(vectorStore: mock)

        let expectation = expectation(description: "concurrent resolve")
        expectation.expectedFulfillmentCount = 1000

        let resultsLock = NSLock()
        var results: [ObjectIdentifier] = []

        for _ in 0..<1000 {
            DispatchQueue.global().async {
                do {
                    let resolved = try DustCoreRegistry.shared.resolveVectorStore()
                    resultsLock.lock()
                    results.append(ObjectIdentifier(resolved))
                    resultsLock.unlock()
                } catch {
                    XCTFail("resolve threw: \(error)")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
        let unique = Set(results)
        XCTAssertEqual(unique.count, 1)
    }
}

// MARK: - Mock implementations

private final class MockVectorStore: DustVectorStore {
    func open(config: [String: String]) async throws {}
    func search(query: [Float], limit: Int) async throws -> [DustVectorSearchResult] { [] }
    func upsert(id: String, vector: [Float], metadata: [String: String]?) async throws {}
    func delete(id: String) async throws {}
    func close() async throws {}
}

private final class MockModelSession: DustModelSession {
    func predict(inputs: [DustInputTensor]) async throws -> [DustOutputTensor] { [] }
    func status() -> DustModelStatus { .ready }
    func priority() -> DustSessionPriority { .interactive }
    func close() async throws {}
}

private final class MockEmbeddingService: DustEmbeddingService {
    func embed(texts: [String]) async throws -> [[Float]] { [] }
    func embeddingDimension() -> Int { 1536 }
    func status() -> DustEmbeddingStatus { .idle }
}

private final class MockModelServer: DustModelServer {
    func loadModel(descriptor: DustModelDescriptor, priority: DustSessionPriority) async throws -> DustModelSession {
        MockModelSession()
    }
    func unloadModel(id: String) async throws {}
    func listModels() async throws -> [DustModelDescriptor] { [] }
    func modelStatus(id: String) async throws -> DustModelStatus { .notLoaded }
}
