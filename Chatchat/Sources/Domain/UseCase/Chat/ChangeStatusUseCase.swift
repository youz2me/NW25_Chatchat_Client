//
//  ChangeStatusUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol ChangeStatusUseCaseProtocol {
    func execute(_ status: UserStatus) async throws
}

// MARK: - Implementation

final class ChangeStatusUseCase: ChangeStatusUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute(_ status: UserStatus) async throws {
        try await chatRepository.changeStatus(status)
    }
}
