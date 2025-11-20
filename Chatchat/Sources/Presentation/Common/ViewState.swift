//
//  ViewState.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import Foundation

/// 뷰 상태 관리
enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String)

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - Equatable (where T: Equatable)

extension ViewState: Equatable where T: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Void State Helper

typealias LoadingState = ViewState<Void>

extension ViewState where T == Void {
    static var successVoid: ViewState<Void> {
        .success(())
    }
}
