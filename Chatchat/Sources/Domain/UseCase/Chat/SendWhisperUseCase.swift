//
//  SendWhisperUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol SendWhisperUseCaseProtocol {
    func execute(targetUserId: String, content: String) async throws
}

// MARK: - Implementation

final class SendWhisperUseCase: SendWhisperUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute(targetUserId: String, content: String) async throws {
        // 입력 검증
        guard !targetUserId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.whisperFailed("대상 사용자를 선택해주세요")
        }

        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw ChatError.whisperFailed("메시지를 입력해주세요")
        }

        // 자기 자신에게 귓속말 불가
        if targetUserId == SessionManager.shared.currentUserId {
            throw ChatError.whisperFailed("자기 자신에게 귓속말을 보낼 수 없습니다")
        }

        try await chatRepository.sendWhisper(targetUserId: targetUserId, content: trimmedContent)
    }
}
