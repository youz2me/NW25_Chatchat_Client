//
//  CreateRoomUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation

// MARK: - Protocol

protocol CreateRoomUseCaseProtocol {
    func execute(name: String) async throws -> ChatRoomEntity
}

// MARK: - Implementation

final class CreateRoomUseCase: CreateRoomUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    func execute(name: String) async throws -> ChatRoomEntity {
        // 입력 검증
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ChatError.unknown("채팅방 이름을 입력해주세요")
        }

        guard trimmedName.count >= 2 else {
            throw ChatError.unknown("채팅방 이름은 2자 이상이어야 합니다")
        }

        return try await roomRepository.createRoom(name: trimmedName)
    }
}
