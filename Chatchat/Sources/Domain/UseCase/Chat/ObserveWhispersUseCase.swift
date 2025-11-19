//
//  ObserveWhispersUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation
import Combine

// MARK: - Protocol

protocol ObserveWhispersUseCaseProtocol {
    func execute() -> AnyPublisher<MessageEntity, Never>
}

// MARK: - Implementation

final class ObserveWhispersUseCase: ObserveWhispersUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    /// 귓속말 구독
    func execute() -> AnyPublisher<MessageEntity, Never> {
        return chatRepository.whisperPublisher
    }
}
