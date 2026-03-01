<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../assets/branding/dust_white.png">
    <source media="(prefers-color-scheme: light)" srcset="../assets/branding/dust_black.png">
    <img alt="dust" src="../assets/branding/dust_black.png" width="200">
  </picture>
</p>

<p align="center"><strong>Device Unified Serving Toolkit</strong></p>

# dust-core-swift

DustCore contract types and protocols for on-device ML — pure Swift, no external dependencies.

**Version: 0.1.0**

## Overview

Defines the shared protocols and value types that ML plugins implement. Contains zero platform-specific code beyond Foundation — runs on iOS 14+ and macOS 12+.

```
dust-core-swift/
├── Package.swift                         # SPM: product "DustCore", iOS 14+ / macOS 12+
├── DustCore.podspec                        # CocoaPods spec (module name: DustCore)
├── VERSION                               # Single source of truth for version string
├── Sources/DustCore/
│   ├── DustCoreVersion.swift               # Version constant
│   ├── Types.swift                       # Enums, structs (Sendable, Equatable, Hashable)
│   ├── Protocols.swift                   # async/await protocols (4 interfaces)
│   └── DustCoreRegistry.swift              # Thread-safe singleton (NSLock)
└── Tests/DustCoreTests/
    ├── DustCoreRegistryTests.swift          # 11 tests
    └── DustCoreTypesTests.swift             # 18 tests
```

## Install

### Swift Package Manager — local

```swift
// Package.swift
dependencies: [
    .package(name: "dust-core-swift", path: "../dust-core-swift"),
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            .product(name: "DustCore", package: "dust-core-swift"),
        ]
    )
]
```

### Swift Package Manager — remote (when published)

```swift
.package(url: "https://github.com/rogelioRuiz/dust-core-swift.git", from: "0.1.0")
```

### CocoaPods

```ruby
pod 'DustCore', '~> 0.1'
```

## Protocols

| Protocol | Methods | Purpose |
|----------|---------|---------|
| `DustModelServer` | `loadModel`, `unloadModel`, `listModels`, `modelStatus` | Model lifecycle |
| `DustModelSession` | `predict`, `status`, `priority`, `close` | Inference |
| `DustVectorStore` | `open`, `search`, `upsert`, `delete`, `close` | Vector search |
| `DustEmbeddingService` | `embed`, `embeddingDimension`, `status` | Text-to-vector |

All methods are `async throws` (Swift concurrency).

## Usage

### Implement a ModelServer

```swift
import DustCore

class MyModelServer: DustModelServer {
    func loadModel(
        descriptor: DustModelDescriptor,
        priority: DustSessionPriority
    ) async throws -> DustModelSession {
        // Load model from descriptor.url, return session
    }

    func unloadModel(id: String) async throws { /* ... */ }
    func listModels() async throws -> [DustModelDescriptor] { /* ... */ }
    func modelStatus(id: String) async throws -> DustModelStatus { /* ... */ }
}
```

### Register and resolve via DustCoreRegistry

```swift
// Register at startup
DustCoreRegistry.shared.register(modelServer: MyModelServer())

// Resolve from anywhere
let server = try DustCoreRegistry.shared.resolveModelServer()
let session = try await server.loadModel(descriptor: desc, priority: .interactive)
let outputs = try await session.predict(inputs: [
    DustInputTensor(name: "input", data: [1.0, 2.0], shape: [1, 2])
])
```

### Create a ModelDescriptor

```swift
let descriptor = DustModelDescriptor(
    id: "my-model",
    name: "My Model",
    format: .gguf,
    sizeBytes: 4_000_000_000,
    version: "1.0",
    url: "/path/to/model.gguf",
    quantization: "Q4_K_M"
)
```

### Error handling

```swift
do {
    let server = try DustCoreRegistry.shared.resolveModelServer()
} catch DustCoreError.serviceNotRegistered(let name) {
    // No ModelServer registered yet
}

do {
    let session = try await server.loadModel(descriptor: desc, priority: .interactive)
} catch DustCoreError.modelNotFound {
    // Model file not found
} catch DustCoreError.inferenceFailed(let detail) {
    print("Inference failed: \(detail ?? "unknown")")
}
```

## Value types

All types are `Sendable`, `Equatable`, and `Hashable`.

| Type | Kind | Fields |
|------|------|--------|
| `DustModelDescriptor` | struct | `id`, `name`, `format`, `sizeBytes`, `version`, `url?`, `sha256?`, `quantization?`, `metadata?` |
| `DustModelStatus` | enum | `.notLoaded`, `.downloading(progress)`, `.verifying`, `.loading`, `.ready`, `.failed(error)`, `.unloading` |
| `DustInputTensor` | struct | `name`, `data: [Float]`, `shape: [Int]` |
| `DustOutputTensor` | struct | `name`, `data: [Float]`, `shape: [Int]` |
| `DustVectorSearchResult` | struct | `id`, `score`, `metadata?` |
| `DustModelFormat` | enum | `.onnx`, `.coreml`, `.tflite`, `.gguf`, `.custom` |
| `DustSessionPriority` | enum | `.background`, `.interactive` |
| `DustEmbeddingStatus` | enum | `.idle`, `.computing`, `.ready`, `.failed` |

## Thread safety

`DustCoreRegistry` uses `NSLock` — all register/resolve operations are serialized. Safe to call from any thread or actor context.

## Test

```bash
cd dust-core-swift
swift test    # 29 XCTest tests (11 registry + 18 types)
```

Requires macOS with Swift toolchain. No Xcode project needed — runs via SPM.

---

<p align="center">
  Part of <a href="../README.md"><strong>dust</strong></a> — Device Unified Serving Toolkit
</p>
