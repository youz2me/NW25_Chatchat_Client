//
//  Response.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

// MARK: - Push Event

enum PushEvent: Sendable {
    case userJoined(roomId: String, userId: String, userName: String)
    case userLeft(roomId: String, userId: String)
    case newMessage(roomId: String, senderId: String, senderName: String, content: String, timestamp: String)
    case whisper(senderId: String, senderName: String, content: String, timestamp: String)
    case typing(roomId: String, userId: String, isTyping: Bool)
    case statusChanged(userId: String, newStatus: UserStatus)
    case roomCreated(roomId: String, roomName: String)
    case unknown(raw: String)
}

extension PushEvent {
    func toMessage() -> MessageEntity? {
        switch self {
        case .newMessage(let roomId, let senderId, let senderName, let content, let timestamp):
            return MessageEntity(
                id: UUID().uuidString,
                roomId: roomId,
                senderId: senderId,
                senderName: senderName,
                content: content,
                type: .normal,
                timestamp: DateParser.parse(timestamp)
            )

        case .whisper(let senderId, let senderName, let content, let timestamp):
            return MessageEntity(
                id: UUID().uuidString,
                roomId: "",
                senderId: senderId,
                senderName: senderName,
                content: content,
                type: .whisper,
                timestamp: DateParser.parse(timestamp)
            )

        default:
            return nil
        }
    }
}

// MARK: - Date Parser

enum DateParser {
    private static let primaryFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackIsoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func parse(_ string: String) -> Date {
        primaryFormatter.date(from: string) ??
        isoFormatter.date(from: string) ??
        fallbackIsoFormatter.date(from: string) ??
        Date()
    }
}
