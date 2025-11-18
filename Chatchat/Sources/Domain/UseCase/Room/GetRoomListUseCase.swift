//
//  GetRoomListUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation

// MARK: - Protocol

protocol GetRoomListUseCaseProtocol {
    func execute() async throws -> [ChatRoomEntity]
}

// MARK: - Implementation

final class GetRoomListUseCase: GetRoomListUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    func execute() async throws -> [ChatRoomEntity] {
        return try await roomRepository.getRoomList()
    }
}
