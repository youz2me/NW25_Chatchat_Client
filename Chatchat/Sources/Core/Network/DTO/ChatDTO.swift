//
//  ChatDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Request DTOs

/// 메시지 전송 요청
struct SendMessageRequestDTO: Encodable {
    let roomId: String
    let content: String
}

/// 귓속말 전송 요청
struct SendWhisperRequestDTO: Encodable {
    let targetUserId: String
    let content: String
}

/// 타이핑 상태 요청
struct TypingRequestDTO: Encodable {
    let roomId: String
    let isTyping: Bool
}

// MARK: - Response DTOs

/// 메시지 전송 응답
struct SendMessageResponseDTO: Decodable {
    let messageId: String
    let timestamp: String
}

/// 귓속말 전송 응답
struct SendWhisperResponseDTO: Decodable {
    let targetId: String
    let content: String
    let timestamp: String
}
