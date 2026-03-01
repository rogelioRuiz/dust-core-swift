import Foundation

/// `@unchecked Sendable` is intentional: thread safety is guaranteed manually via
/// `NSLock` on every property access. Do NOT add stored properties without wrapping
/// them in the lock — the Swift concurrency checker cannot enforce this for us.
public final class DustCoreRegistry: @unchecked Sendable {

    public static let shared = DustCoreRegistry()

    private let lock = NSLock()
    private var _vectorStore: (any DustVectorStore)?
    private var _modelServer: (any DustModelServer)?
    private var _embeddingService: (any DustEmbeddingService)?

    private init() {}

    // MARK: - Register

    public func register(vectorStore: any DustVectorStore) {
        lock.lock()
        defer { lock.unlock() }
        _vectorStore = vectorStore
    }

    public func register(modelServer: any DustModelServer) {
        lock.lock()
        defer { lock.unlock() }
        _modelServer = modelServer
    }

    public func register(embeddingService: any DustEmbeddingService) {
        lock.lock()
        defer { lock.unlock() }
        _embeddingService = embeddingService
    }

    // MARK: - Resolve

    public func resolveVectorStore() throws -> any DustVectorStore {
        lock.lock()
        defer { lock.unlock() }
        guard let store = _vectorStore else {
            throw DustCoreError.serviceNotRegistered(serviceName: "VectorStore")
        }
        return store
    }

    public func resolveModelServer() throws -> any DustModelServer {
        lock.lock()
        defer { lock.unlock() }
        guard let server = _modelServer else {
            throw DustCoreError.serviceNotRegistered(serviceName: "ModelServer")
        }
        return server
    }

    public func resolveEmbeddingService() throws -> any DustEmbeddingService {
        lock.lock()
        defer { lock.unlock() }
        guard let service = _embeddingService else {
            throw DustCoreError.serviceNotRegistered(serviceName: "EmbeddingService")
        }
        return service
    }

    // MARK: - Test support

    /// Resets all registrations. For testing only — exposed as `public` so
    /// downstream packages can reset global state in their test suites.
    public func resetForTesting() {
        lock.lock()
        defer { lock.unlock() }
        _vectorStore = nil
        _modelServer = nil
        _embeddingService = nil
    }
}
