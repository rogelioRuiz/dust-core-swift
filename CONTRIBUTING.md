# Contributing to dust-core-swift

Thanks for your interest in contributing! This guide will help you get set up and understand our development workflow.

## Prerequisites

- **macOS** with Swift 5.9+ toolchain
- **Git**

dust-core-swift has no sibling dependencies.

## Getting Started

```bash
git clone https://github.com/rogelioRuiz/dust-core-swift.git

cd dust-core-swift

# Build
swift build

# Run tests
swift test
```

## Project Structure

```
Sources/DustCore/
  DustCoreRegistry.swift    # Thread-safe descriptor store
  DustCoreVersion.swift     # Library version constant
  Protocols.swift           # Core ML session and engine protocols
  Types.swift               # Shared value types and error definitions

Tests/DustCoreTests/
  DustCoreRegistryTests.swift  # 11 tests
  DustCoreTypesTests.swift     # 18 tests
```

## Making Changes

### 1. Create a branch

```bash
git checkout -b feat/my-feature
```

### 2. Make your changes

- Follow existing Swift conventions in the codebase
- Add tests for new functionality

### 3. Add the license header

All `.swift` files must include the Apache 2.0 header:

```swift
//
// Copyright 2026 Rogelio Ruiz Perez
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
```

### 4. Run checks

```bash
swift test          # All 29 tests must pass
swift build         # Clean build
```

### 5. Commit with a conventional message

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add model capability descriptor
fix: correct Sendable conformance on registry
docs: update README usage examples
```

### 6. Open a pull request

Push your branch and open a PR against `main`.

## Reporting Issues

- **Bugs**: Open an issue with steps to reproduce
- **Features**: Open an issue describing the use case and proposed API

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Please be respectful and constructive.

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
