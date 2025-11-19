//
//  ObserveMessagesUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation
import Combine

// MARK: - Protocol

protocol ObserveMessagesUseCaseProtocol {
    func execute() -> AnyPublisher<MessageEntity, Never>
    func execute(roomId: String) -> AnyPublisher<MessageEntity, Never>
}

// MARK: - Implementation

final class ObserveMessagesUseCase: ObserveMessagesUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    /// 모든 메시지 구독
    func execute() -> AnyPublisher<MessageEntity, Never> {
        return chatRepository.messagePublisher
    }

    /// 특정 방의 메시지만 구독
    func execute(roomId: String) -> AnyPublisher<MessageEntity, Never> {
        return chatRepository.messagePublisher
            .filter { $0.roomId == roomId }
            .eraseToAnyPublisher()
    }
}
