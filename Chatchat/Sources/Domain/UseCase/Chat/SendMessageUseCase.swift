//
//  SendMessageUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol SendMessageUseCaseProtocol {
    func execute(content: String) async throws
    func execute(roomId: String, content: String) async throws
}

// MARK: - Implementation

final class SendMessageUseCase: SendMessageUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol
    private let roomRepository: RoomRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol, roomRepository: RoomRepositoryProtocol) {
        self.chatRepository = chatRepository
        self.roomRepository = roomRepository
    }

    /// 현재 방에 메시지 전송
    func execute(content: String) async throws {
        let roomId = roomRepository.currentRoomId
        try await execute(roomId: roomId, content: content)
    }

    /// 특정 방에 메시지 전송
    func execute(roomId: String, content: String) async throws {
        // 입력 검증
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw ChatError.messageSendFailed("메시지를 입력해주세요")
        }

        try await chatRepository.sendMessage(roomId: roomId, content: trimmedContent)
    }
}
