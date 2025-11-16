//
//  SessionEntity.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

/// 로그인 세션 정보
struct SessionEntity: Sendable, Equatable {
    let token: String
    let userId: String
    let userName: String
    let loginAt: Date

    init(token: String, userId: String, userName: String) {
        self.token = token
        self.userId = userId
        self.userName = userName
        self.loginAt = Date()
    }

    /// 세션 유효 여부 (토큰 존재 확인)
    var isValid: Bool {
        !token.isEmpty && !userId.isEmpty
    }
}

/// 세션 관리자 (싱글톤)
final class SessionManager: @unchecked Sendable {
    static let shared = SessionManager()

    private let lock = NSLock()
    private var _currentSession: SessionEntity?

    var currentSession: SessionEntity? {
        lock.lock()
        defer { lock.unlock() }
        return _currentSession
    }

    var isLoggedIn: Bool {
        currentSession != nil
    }

    var currentUserId: String? {
        currentSession?.userId
    }

    var currentUserName: String? {
        currentSession?.userName
    }

    private init() {}

    func setSession(_ session: SessionEntity?) {
        lock.lock()
        _currentSession = session
        lock.unlock()
    }

    func clearSession() {
        setSession(nil)
    }
}
