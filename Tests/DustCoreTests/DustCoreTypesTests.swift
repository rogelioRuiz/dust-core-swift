import XCTest
@testable import DustCore

final class DustCoreTypesTests: XCTestCase {

    // MARK: - M3-T4: Version constant

    func testDustCoreVersionAccessible() {
        XCTAssertEqual(DustCoreVersion.current, "0.1.0")
        XCTAssertFalse(DustCoreVersion.current.isEmpty)
    }

    // MARK: - M1-T1: Protocols compile — mock implementing VectorStore

    func testVectorStoreProtocolCompiles() async throws {
        let mock = MockVectorStore()
        try await mock.open(config: [:])
        let results = try await mock.search(query: [0.1, 0.2, 0.3], limit: 5)
        XCTAssertEqual(results.count, 0)
        try await mock.close()
    }

    func testModelSessionProtocolCompiles() async throws {
        let mock = MockModelSession()
        let outputs = try await mock.predict(inputs: [])
        XCTAssertEqual(outputs.count, 0)
        XCTAssertEqual(mock.status(), .ready)
        XCTAssertEqual(mock.priority(), .interactive)
    }

    func testEmbeddingServiceProtocolCompiles() async throws {
        let mock = MockEmbeddingService()
        let embeddings = try await mock.embed(texts: ["hello"])
        XCTAssertEqual(embeddings.count, 0)
        XCTAssertEqual(mock.embeddingDimension(), 1536)
        XCTAssertEqual(mock.status(), .idle)
    }

    func testModelServerProtocolCompiles() async throws {
        let mock = MockModelServer()
        let descriptor = DustModelDescriptor(
            id: "test", name: "Test", format: .gguf, sizeBytes: 100, version: "1.0"
        )
        let session = try await mock.loadModel(descriptor: descriptor, priority: .interactive)
        XCTAssertEqual(session.status(), .ready)
    }

    // MARK: - M1-T3: ModelDescriptor value semantics

    func testModelDescriptorEquality() {
        let a = DustModelDescriptor(
            id: "llama-3.2-1b",
            name: "Llama 3.2 1B",
            format: .gguf,
            sizeBytes: 1_200_000_000,
            version: "1.0.0",
            quantization: "Q4_K_M",
            metadata: ["source": "huggingface"]
        )
        let b = DustModelDescriptor(
            id: "llama-3.2-1b",
            name: "Llama 3.2 1B",
            format: .gguf,
            sizeBytes: 1_200_000_000,
            version: "1.0.0",
            quantization: "Q4_K_M",
            metadata: ["source": "huggingface"]
        )
        XCTAssertEqual(a, b)
    }

    func testModelDescriptorInequality() {
        let a = DustModelDescriptor(id: "a", name: "A", format: .onnx, sizeBytes: 100, version: "1.0")
        let b = DustModelDescriptor(id: "b", name: "A", format: .onnx, sizeBytes: 100, version: "1.0")
        XCTAssertNotEqual(a, b)
    }

    func testModelDescriptorHashable() {
        let a = DustModelDescriptor(id: "x", name: "X", format: .gguf, sizeBytes: 100, version: "1.0")
        let b = DustModelDescriptor(id: "x", name: "X", format: .gguf, sizeBytes: 100, version: "1.0")
        var set = Set<DustModelDescriptor>()
        set.insert(a)
        set.insert(b)
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - M1-T4: SessionPriority ordering

    func testSessionPriorityOrdering() {
        XCTAssertEqual(DustSessionPriority.background.rawValue, 0)
        XCTAssertEqual(DustSessionPriority.interactive.rawValue, 1)
        XCTAssertTrue(DustSessionPriority.background < DustSessionPriority.interactive)
    }

    // MARK: - M1-T5: ModelStatus associated values

    func testModelStatusDownloadingExtractsProgress() {
        let status = DustModelStatus.downloading(progress: 0.47)
        if case .downloading(let progress) = status {
            XCTAssertEqual(progress, 0.47, accuracy: 0.001)
        } else {
            XCTFail("Expected .downloading status")
        }
    }

    func testModelStatusFailedExtractsError() {
        let status = DustModelStatus.failed(error: .memoryExhausted)
        if case .failed(let error) = status {
            XCTAssertEqual(error, .memoryExhausted)
        } else {
            XCTFail("Expected .failed status")
        }
    }

    // MARK: - Sendable check

    func testTypesAreSendable() async {
        let descriptor = DustModelDescriptor(id: "x", name: "X", format: .gguf, sizeBytes: 100, version: "1.0")
        let tensor = DustInputTensor(name: "input", data: [1.0, 2.0], shape: [1, 2])

        let result = await withCheckedContinuation { continuation in
            Task.detached {
                continuation.resume(returning: (descriptor, tensor))
            }
        }
        XCTAssertEqual(result.0.id, "x")
        XCTAssertEqual(result.1.name, "input")
    }

    // MARK: - Additional type checks

    func testVectorSearchResultEquality() {
        let a = DustVectorSearchResult(id: "doc1", score: 0.95, metadata: ["key": "val"])
        let b = DustVectorSearchResult(id: "doc1", score: 0.95, metadata: ["key": "val"])
        XCTAssertEqual(a, b)
    }

    func testInputTensorEquality() {
        let a = DustInputTensor(name: "input", data: [1.0, 2.0, 3.0], shape: [1, 3])
        let b = DustInputTensor(name: "input", data: [1.0, 2.0, 3.0], shape: [1, 3])
        XCTAssertEqual(a, b)
    }

    func testOutputTensorEquality() {
        let a = DustOutputTensor(name: "output", data: [0.1, 0.9], shape: [1, 2])
        let b = DustOutputTensor(name: "output", data: [0.1, 0.9], shape: [1, 2])
        XCTAssertEqual(a, b)
    }

    func testDustCoreErrorEquality() {
        XCTAssertEqual(DustCoreError.modelNotFound, DustCoreError.modelNotFound)
        XCTAssertEqual(DustCoreError.invalidInput(detail: "bad shape"), DustCoreError.invalidInput(detail: "bad shape"))
        XCTAssertNotEqual(DustCoreError.modelNotFound, DustCoreError.timeout)
    }

    func testEmbeddingStatusCases() {
        XCTAssertEqual(DustEmbeddingStatus.idle.rawValue, "idle")
        XCTAssertEqual(DustEmbeddingStatus.computing.rawValue, "computing")
        XCTAssertEqual(DustEmbeddingStatus.ready.rawValue, "ready")
        XCTAssertEqual(DustEmbeddingStatus.failed.rawValue, "failed")
    }

    func testModelFormatCases() {
        XCTAssertEqual(DustModelFormat.onnx.rawValue, "onnx")
        XCTAssertEqual(DustModelFormat.coreml.rawValue, "coreml")
        XCTAssertEqual(DustModelFormat.tflite.rawValue, "tflite")
        XCTAssertEqual(DustModelFormat.gguf.rawValue, "gguf")
        XCTAssertEqual(DustModelFormat.custom.rawValue, "custom")
    }
}

// MARK: - Mock implementations

private final class MockVectorStore: DustVectorStore {
    func open(config: [String: String]) async throws {}
    func search(query: [Float], limit: Int) async throws -> [DustVectorSearchResult] { return [] }
    func upsert(id: String, vector: [Float], metadata: [String: String]?) async throws {}
    func delete(id: String) async throws {}
    func close() async throws {}
}

private final class MockModelSession: DustModelSession {
    func predict(inputs: [DustInputTensor]) async throws -> [DustOutputTensor] { return [] }
    func status() -> DustModelStatus { return .ready }
    func priority() -> DustSessionPriority { return .interactive }
    func close() async throws {}
}

private final class MockEmbeddingService: DustEmbeddingService {
    func embed(texts: [String]) async throws -> [[Float]] { return [] }
    func embeddingDimension() -> Int { return 1536 }
    func status() -> DustEmbeddingStatus { return .idle }
}

private final class MockModelServer: DustModelServer {
    func loadModel(descriptor: DustModelDescriptor, priority: DustSessionPriority) async throws -> DustModelSession {
        return MockModelSession()
    }
    func unloadModel(id: String) async throws {}
    func listModels() async throws -> [DustModelDescriptor] { return [] }
    func modelStatus(id: String) async throws -> DustModelStatus { return .notLoaded }
}
