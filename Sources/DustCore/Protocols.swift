import Foundation

// MARK: - VectorStore

public protocol DustVectorStore: AnyObject {
    func open(config: [String: String]) async throws
    func search(query: [Float], limit: Int) async throws -> [DustVectorSearchResult]
    func upsert(id: String, vector: [Float], metadata: [String: String]?) async throws
    func delete(id: String) async throws
    func close() async throws
}

// MARK: - ModelSession

public protocol DustModelSession: AnyObject {
    func predict(inputs: [DustInputTensor]) async throws -> [DustOutputTensor]
    func status() -> DustModelStatus
    func priority() -> DustSessionPriority
    func close() async throws
}

// MARK: - EmbeddingService

public protocol DustEmbeddingService: AnyObject {
    func embed(texts: [String]) async throws -> [[Float]]
    func embeddingDimension() -> Int
    func status() -> DustEmbeddingStatus
}

// MARK: - ModelSessionFactory

/// Creates `DustModelSession` instances on demand.
///
/// Task libraries (LLM, ONNX, …) conform to this protocol so that
/// DustServe can delegate session creation without knowing the
/// concrete inference engine.
public protocol DustModelSessionFactory: Sendable {
    func makeSession(
        descriptor: DustModelDescriptor,
        priority: DustSessionPriority
    ) async throws -> any DustModelSession
}

// MARK: - ModelServer

public protocol DustModelServer: AnyObject {
    func loadModel(descriptor: DustModelDescriptor, priority: DustSessionPriority) async throws -> DustModelSession
    func unloadModel(id: String) async throws
    func listModels() async throws -> [DustModelDescriptor]
    func modelStatus(id: String) async throws -> DustModelStatus
}
