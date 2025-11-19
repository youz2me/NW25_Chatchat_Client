//
//  Injected.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

/// 의존성 주입 Property Wrapper - 사용법: @Injected var repository: AuthRepositoryProtocol
@propertyWrapper
struct Injected<T> {
    private let container: DependencyContainer
    private let lock = NSLock()
    private var cachedValue: T?
    
    init() {
        self.container = DIContainer.shared
    }
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    var wrappedValue: T {
        mutating get {
            lock.lock()
            defer { lock.unlock() }

            if let cached = cachedValue {
                return cached
            }

            let resolved = container.resolve(T.self)
            cachedValue = resolved
            return resolved
        }
    }
}

/// 옵셔널 의존성 주입 Property Wrapper - 등록되지 않은 의존성은 nil 반환
@propertyWrapper
struct InjectedOptional<T> {
    private let container: DependencyContainer
    private let lock = NSLock()
    private var cachedValue: T?
    private var didResolve = false
    
    init() {
        self.container = DIContainer.shared
    }
    
    var wrappedValue: T? {
        mutating get {
            lock.lock()
            defer { lock.unlock() }

            if didResolve { return cachedValue }

            cachedValue = container.resolveOptional(T.self)
            didResolve = true
            return cachedValue
        }
    }
}
