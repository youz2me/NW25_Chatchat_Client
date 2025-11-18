//
//  JoinRoomUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation

// MARK: - Protocol

protocol JoinRoomUseCaseProtocol {
    func execute(roomId: String) async throws
    func execute(room: ChatRoomEntity) async throws
}

// MARK: - Implementation

final class JoinRoomUseCase: JoinRoomUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    func execute(roomId: String) async throws {
        guard !roomId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.roomNotFound
        }

        try await roomRepository.joinRoom(roomId)
    }

    func execute(room: ChatRoomEntity) async throws {
        try await execute(roomId: room.id)
    }
}
