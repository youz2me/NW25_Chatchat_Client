//
//  SocketMessage.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

/// 소켓 메시지 래퍼
struct SocketMessage: Sendable {
    let raw: String
    let timestamp: Date

    init(raw: String) {
        self.raw = raw
        self.timestamp = Date()
    }
}

/// 서버 이벤트 타입
enum ServerEvent: Sendable {
    case connected
    case disconnected(Error?)
    case messageReceived(SocketMessage)
}

extension ServerEvent {
    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    var isDisconnected: Bool {
        if case .disconnected = self { return true }
        return false
    }

    var message: SocketMessage? {
        if case .messageReceived(let msg) = self { return msg }
        return nil
    }
}
