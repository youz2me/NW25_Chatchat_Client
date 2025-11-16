//
//  MessageEntity.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

struct MessageEntity: Identifiable, Equatable, Sendable {
    let id: String
    let roomId: String
    let senderId: String
    let senderName: String
    let content: String
    let type: MessageType
    let targetUserId: String?
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        roomId: String,
        senderId: String,
        senderName: String,
        content: String,
        type: MessageType = .normal,
        targetUserId: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.roomId = roomId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.type = type
        self.targetUserId = targetUserId
        self.timestamp = timestamp
    }

    var isWhisper: Bool {
        type == .whisper
    }

    var isSystem: Bool {
        type == .system
    }

    var isFromMe: Bool {
        senderId == SessionManager.shared.currentSession?.userId
    }
}

enum MessageType: String, Sendable {
    case normal = "NORMAL"
    case whisper = "WHISPER"
    case system = "SYSTEM"
}

extension MessageEntity {
    /// 시스템 메시지 생성
    static func system(roomId: String, content: String) -> MessageEntity {
        MessageEntity(
            roomId: roomId,
            senderId: "SYSTEM",
            senderName: "시스템",
            content: content,
            type: .system
        )
    }

    /// 입장 메시지
    static func userJoined(roomId: String, userName: String) -> MessageEntity {
        system(roomId: roomId, content: "\(userName)님이 입장했습니다.")
    }

    /// 퇴장 메시지
    static func userLeft(roomId: String, userName: String) -> MessageEntity {
        system(roomId: roomId, content: "\(userName)님이 퇴장했습니다.")
    }

    /// 타임스탬프 포맷
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: timestamp)
    }
}
