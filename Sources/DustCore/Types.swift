import Foundation

// MARK: - ModelFormat

public enum DustModelFormat: String, Equatable, Hashable, Sendable, CaseIterable {
    case onnx = "onnx"
    case coreml = "coreml"
    case tflite = "tflite"
    case gguf = "gguf"
    case custom = "custom"
}

// MARK: - SessionPriority

public enum DustSessionPriority: Int, Equatable, Hashable, Sendable, Comparable {
    case background = 0
    case interactive = 1

    public static func < (lhs: DustSessionPriority, rhs: DustSessionPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - ModelStatus

public enum DustModelStatus: Equatable, Sendable {
    case notLoaded
    case downloading(progress: Float)
    case verifying
    case loading
    case ready
    case failed(error: DustCoreError)
    case unloading
}

// MARK: - EmbeddingStatus

public enum DustEmbeddingStatus: String, Equatable, Hashable, Sendable, CaseIterable {
    case idle = "idle"
    case computing = "computing"
    case ready = "ready"
    case failed = "failed"
}

// MARK: - ModelDescriptor

public struct DustModelDescriptor: Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let format: DustModelFormat
    public let sizeBytes: Int64
    public let version: String
    public let url: String?
    public let sha256: String?
    public let quantization: String?
    public let metadata: [String: String]?

    public init(
        id: String,
        name: String,
        format: DustModelFormat,
        sizeBytes: Int64,
        version: String,
        url: String? = nil,
        sha256: String? = nil,
        quantization: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.name = name
        self.format = format
        self.sizeBytes = sizeBytes
        self.version = version
        self.url = url
        self.sha256 = sha256
        self.quantization = quantization
        self.metadata = metadata
    }
}

// MARK: - VectorSearchResult

public struct DustVectorSearchResult: Equatable, Sendable {
    public let id: String
    public let score: Float
    public let metadata: [String: String]?

    public init(id: String, score: Float, metadata: [String: String]? = nil) {
        self.id = id
        self.score = score
        self.metadata = metadata
    }
}

// MARK: - InputTensor

public struct DustInputTensor: Equatable, Sendable {
    public let name: String
    public let data: [Float]
    public let shape: [Int]

    public init(name: String, data: [Float], shape: [Int]) {
        self.name = name
        self.data = data
        self.shape = shape
    }
}

// MARK: - OutputTensor

public struct DustOutputTensor: Equatable, Sendable {
    public let name: String
    public let data: [Float]
    public let shape: [Int]

    public init(name: String, data: [Float], shape: [Int]) {
        self.name = name
        self.data = data
        self.shape = shape
    }
}

// MARK: - DustCoreError

public enum DustCoreError: Error, Equatable, Sendable {
    case modelNotFound
    case modelNotReady
    case modelCorrupted
    case formatUnsupported
    case sessionClosed
    case sessionLimitReached
    case invalidInput(detail: String? = nil)
    case inferenceFailed(detail: String? = nil)
    case memoryExhausted
    case downloadFailed(detail: String? = nil)
    case storageFull(detail: String? = nil)
    case networkPolicyBlocked(detail: String? = nil)
    case verificationFailed(detail: String? = nil)
    case cancelled
    case timeout
    case serviceNotRegistered(serviceName: String)
    case unknownError(message: String? = nil)
}
