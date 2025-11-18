//
//  LeaveRoomUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation

// MARK: - Protocol

protocol LeaveRoomUseCaseProtocol {
    func execute(roomId: String) async throws
    func execute() async throws
}

// MARK: - Implementation

final class LeaveRoomUseCase: LeaveRoomUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    /// 특정 방 퇴장
    func execute(roomId: String) async throws {
        // 로비 퇴장 불가
        guard roomId != ChatRoomEntity.lobbyId else {
            throw ChatError.cannotLeaveLobby
        }

        try await roomRepository.leaveRoom(roomId)
    }

    /// 현재 방 퇴장
    func execute() async throws {
        let currentRoomId = roomRepository.currentRoomId
        try await execute(roomId: currentRoomId)
    }
}
