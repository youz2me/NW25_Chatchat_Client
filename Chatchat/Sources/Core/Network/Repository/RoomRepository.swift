//
//  RoomRepository.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

final class RoomRepository: RoomRepositoryProtocol {

    // MARK: - Dependencies

    private let socketClient: SocketClientProtocol

    // MARK: - State

    private var _currentRoomId: String = ChatRoomEntity.lobbyId
    private let currentRoomSubject = CurrentValueSubject<String, Never>(ChatRoomEntity.lobbyId)

    var currentRoomId: String { _currentRoomId }

    var currentRoomPublisher: AnyPublisher<String, Never> {
        currentRoomSubject.eraseToAnyPublisher()
    }

    // MARK: - Publishers

    private let userJoinedSubject = PassthroughSubject<(roomId: String, user: UserEntity), Never>()
    private let userLeftSubject = PassthroughSubject<(roomId: String, userId: String), Never>()
    private let roomCreatedSubject = PassthroughSubject<ChatRoomEntity, Never>()

    var userJoinedPublisher: AnyPublisher<(roomId: String, user: UserEntity), Never> {
        userJoinedSubject.eraseToAnyPublisher()
    }

    var userLeftPublisher: AnyPublisher<(roomId: String, userId: String), Never> {
        userLeftSubject.eraseToAnyPublisher()
    }

    var roomCreatedPublisher: AnyPublisher<ChatRoomEntity, Never> {
        roomCreatedSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(socketClient: SocketClientProtocol) {
        self.socketClient = socketClient
        setupEventHandling()
    }

    private func setupEventHandling() {
        socketClient.eventPublisher
            .compactMap { event -> SocketMessage? in
                if case .messageReceived(let message) = event {
                    return message
                }
                return nil
            }
            .filter { MessageParser.isPushMessage($0.raw) }
            .sink { [weak self] message in
                self?.handlePushEvent(message.raw)
            }
            .store(in: &cancellables)
    }

    private func handlePushEvent(_ raw: String) {
        let event = MessageParser.parsePushEvent(raw)

        switch event {
        case .userJoined(let roomId, let userId, let userName):
            let user = UserEntity(id: userId, name: userName, status: .online)
            userJoinedSubject.send((roomId, user))

        case .userLeft(let roomId, let userId):
            userLeftSubject.send((roomId, userId))

        case .roomCreated(let roomId, let roomName):
            let room = ChatRoomEntity(
                id: roomId,
                name: roomName,
                creatorId: "",
                userCount: 1,
                createdAt: Date()
            )
            roomCreatedSubject.send(room)

        default:
            break
        }
    }

    // MARK: - Methods

    func createRoom(name: String) async throws -> ChatRoomEntity {
        let request = Request.createRoom(name: name)
        let response = try await sendRequest(request)

        guard response.isSuccess,
              let data = response.data,
              let roomId = data["roomId"]?.value as? String else {
            throw ChatError.unknown(response.message)
        }

        let roomName = data["roomName"]?.value as? String ?? name

        return ChatRoomEntity(
            id: roomId,
            name: roomName,
            creatorId: SessionManager.shared.currentUserId ?? "",
            userCount: 1,
            createdAt: Date()
        )
    }

    func getRoomList() async throws -> [ChatRoomEntity] {
        let request = Request.getRoomList()
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.unknown(response.message)
        }

        return MessageParser.parseRoomList(from: response)
    }

    func joinRoom(_ roomId: String) async throws {
        let request = Request.joinRoom(roomId)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            if let errorCode = response.errorCode,
               let code = ProtocolErrorCode(rawValue: errorCode) {
                throw ChatError.from(protocolError: code)
            }
            throw ChatError.roomNotFound
        }

        _currentRoomId = roomId
        currentRoomSubject.send(roomId)
    }

    func leaveRoom(_ roomId: String) async throws {
        guard roomId != ChatRoomEntity.lobbyId else {
            throw ChatError.cannotLeaveLobby
        }

        let request = Request.leaveRoom(roomId)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            if let errorCode = response.errorCode,
               let code = ProtocolErrorCode(rawValue: errorCode) {
                throw ChatError.from(protocolError: code)
            }
            throw ChatError.unknown(response.message)
        }

        _currentRoomId = ChatRoomEntity.lobbyId
        currentRoomSubject.send(ChatRoomEntity.lobbyId)
    }

    func getRoomUsers(_ roomId: String) async throws -> [UserEntity] {
        let request = Request.getRoomUsers(roomId)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.unknown(response.message)
        }

        return MessageParser.parseRoomUsers(from: response)
    }

    // MARK: - Private Helpers

    private func sendRequest(_ request: Request) async throws -> RawResponse {
        do {
            let responseString = try await socketClient.sendAndWait(request.rawString)
            guard let response = MessageParser.parseResponse(responseString) else {
                throw ChatError.unknown("응답 파싱 실패")
            }
            return response
        } catch let error as SocketError {
            throw ChatError.from(socketError: error)
        }
    }

    func resetToLobby() {
        _currentRoomId = ChatRoomEntity.lobbyId
        currentRoomSubject.send(ChatRoomEntity.lobbyId)
    }
}
