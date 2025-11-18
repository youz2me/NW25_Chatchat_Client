//
//  ObserveRoomEventsUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/18/25.
//

import Foundation
import Combine

// MARK: - Room Event Types

enum RoomEvent {
    case userJoined(roomId: String, user: UserEntity)
    case userLeft(roomId: String, userId: String)
    case roomCreated(room: ChatRoomEntity)
}

// MARK: - Protocol

protocol ObserveRoomEventsUseCaseProtocol {
    func observeUserJoined() -> AnyPublisher<(roomId: String, user: UserEntity), Never>
    func observeUserLeft() -> AnyPublisher<(roomId: String, userId: String), Never>
    func observeRoomCreated() -> AnyPublisher<ChatRoomEntity, Never>
    func observeAllEvents() -> AnyPublisher<RoomEvent, Never>
}

// MARK: - Implementation

final class ObserveRoomEventsUseCase: ObserveRoomEventsUseCaseProtocol {

    private let roomRepository: RoomRepositoryProtocol

    init(roomRepository: RoomRepositoryProtocol) {
        self.roomRepository = roomRepository
    }

    func observeUserJoined() -> AnyPublisher<(roomId: String, user: UserEntity), Never> {
        return roomRepository.userJoinedPublisher
    }

    func observeUserLeft() -> AnyPublisher<(roomId: String, userId: String), Never> {
        return roomRepository.userLeftPublisher
    }

    func observeRoomCreated() -> AnyPublisher<ChatRoomEntity, Never> {
        return roomRepository.roomCreatedPublisher
    }

    func observeAllEvents() -> AnyPublisher<RoomEvent, Never> {
        let joined = roomRepository.userJoinedPublisher
            .map { RoomEvent.userJoined(roomId: $0.roomId, user: $0.user) }

        let left = roomRepository.userLeftPublisher
            .map { RoomEvent.userLeft(roomId: $0.roomId, userId: $0.userId) }

        let created = roomRepository.roomCreatedPublisher
            .map { RoomEvent.roomCreated(room: $0) }

        return Publishers.Merge3(joined, left, created)
            .eraseToAnyPublisher()
    }
}
