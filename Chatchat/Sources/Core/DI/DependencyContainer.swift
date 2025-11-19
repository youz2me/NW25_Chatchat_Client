//
//  DependencyContainer.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

// MARK: - Protocols

protocol DependencyRegistrable {
    func register<T>(_ dependency: T, for type: T.Type)
    func register<T>(_ factory: @escaping () -> T, for type: T.Type)
}

protocol DependencyResolvable {
    func resolve<T>(_ type: T.Type) -> T
    func resolveOptional<T>(_ type: T.Type) -> T?
}

protocol AssemblerRegistrable {
    func register(assemblers: [DependencyAssembler])
}

typealias DependencyContainer = DependencyRegistrable & DependencyResolvable

// MARK: - Entry Type

private enum DependencyEntry {
    case instance(Any)
    case factory(() -> Any)
}

// MARK: - Implementation

final class DIContainer: DependencyContainer, AssemblerRegistrable {

    // MARK: - Singleton

    static let shared = DIContainer()

    // MARK: - Properties

    private var dependencies: [ObjectIdentifier: DependencyEntry] = [:]
    private let queue = DispatchQueue(label: "com.chatchat.di.queue", qos: .userInitiated)

    // MARK: - Initialization

    private init() {}

    // MARK: - Registration

    func register<T>(_ dependency: T, for type: T.Type) {
        queue.sync {
            let key = ObjectIdentifier(type)
            dependencies[key] = .instance(dependency)
        }
    }

    func register<T>(_ factory: @escaping () -> T, for type: T.Type) {
        queue.sync {
            let key = ObjectIdentifier(type)
            dependencies[key] = .factory(factory)
        }
    }

    // MARK: - Resolution

    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = resolveOptional(type) else {
            fatalError("[\(Self.self)] \(type) is not registered")
        }
        return resolved
    }

    func resolveOptional<T>(_ type: T.Type) -> T? {
        let entry: DependencyEntry? = queue.sync {
            let key = ObjectIdentifier(type)
            return dependencies[key]
        }

        guard let entry = entry else {
            return nil
        }

        switch entry {
        case .instance(let service):
            return service as? T
        case .factory(let factory):
            return factory() as? T
        }
    }

    // MARK: - Assembler

    func register(assemblers: [DependencyAssembler]) {
        assemblers.forEach { $0.assemble(to: self) }
    }

    // MARK: - Reset (for testing)

    func reset() {
        queue.sync {
            dependencies.removeAll()
        }
    }
}
