//
//  GetUserListUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol GetUserListUseCaseProtocol {
    func execute() async throws -> [UserEntity]
}

// MARK: - Implementation

final class GetUserListUseCase: GetUserListUseCaseProtocol {

    private let chatRepository: ChatRepositoryProtocol

    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }

    func execute() async throws -> [UserEntity] {
        return try await chatRepository.getUserList()
    }
}
