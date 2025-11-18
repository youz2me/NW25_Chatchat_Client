//
//  GetRoomUsersUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation

// MARK: - Protocol

protocol GetRoomUsersUseCaseProtocol {
    func execute(roomId: String) async throws -> [UserEntity]
    func execute() async throws -> [UserEntity]
}

// MARK: - Implementation

final class GetRoomUsersUseCase: GetRoomUsersUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    /// 특정 방의 사용자 목록
    func execute(roomId: String) async throws -> [UserEntity] {
        return try await roomRepository.getRoomUsers(roomId)
    }

    /// 현재 방의 사용자 목록
    func execute() async throws -> [UserEntity] {
        let currentRoomId = roomRepository.currentRoomId
        return try await execute(roomId: currentRoomId)
    }
}
