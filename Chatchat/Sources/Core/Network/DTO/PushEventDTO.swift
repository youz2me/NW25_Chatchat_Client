//
//  PushEventDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Push Event Types

enum PushEventType: String {
    case newMessage = "NEW_MSG"
    case whisper = "WHISPER"
    case userJoined = "USER_JOINED"
    case userLeft = "USER_LEFT"
    case typing = "TYPING"
    case statusChanged = "STATUS_CHANGED"
    case roomCreated = "ROOM_CREATED"
}

// MARK: - Push Event DTOs

/// 새 메시지 PUSH
struct NewMessagePushDTO: Decodable {
    let roomId: String
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: String

    func toMessage() -> MessageEntity {
        MessageEntity(
            id: UUID().uuidString,
            roomId: roomId,
            senderId: senderId,
            senderName: senderName,
            content: content,
            type: .normal,
            timestamp: parseTimestamp(timestamp)
        )
    }

    private func parseTimestamp(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string) ?? Date()
    }
}

/// 귓속말 PUSH
struct WhisperPushDTO: Decodable {
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: String

    func toMessage(targetUserId: String?) -> MessageEntity {
        MessageEntity(
            id: UUID().uuidString,
            roomId: "",
            senderId: senderId,
            senderName: senderName,
            content: content,
            type: .whisper,
            targetUserId: targetUserId,
            timestamp: parseTimestamp(timestamp)
        )
    }

    private func parseTimestamp(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string) ?? Date()
    }
}

/// 사용자 입장 PUSH
struct UserJoinedPushDTO: Decodable {
    let roomId: String
    let userId: String
    let userName: String

    func toUser() -> UserEntity {
        UserEntity(id: userId, name: userName, status: .online)
    }
}

/// 사용자 퇴장 PUSH
struct UserLeftPushDTO: Decodable {
    let roomId: String
    let userId: String
}

/// 타이핑 상태 PUSH
struct TypingPushDTO: Decodable {
    let roomId: String
    let userId: String
    let isTyping: Bool
}

/// 상태 변경 PUSH
struct StatusChangedPushDTO: Decodable {
    let userId: String
    let status: String

    var userStatus: UserStatus {
        UserStatus(rawValue: status) ?? .offline
    }
}

/// 채팅방 생성 PUSH
struct RoomCreatedPushDTO: Decodable {
    let roomId: String
    let roomName: String

    func toChatRoomEntity() -> ChatRoomEntity {
        ChatRoomEntity(id: roomId, name: roomName, userCount: 1)
    }
}
