//
//  ChatRepository.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

final class ChatRepository: ChatRepositoryProtocol {

    // MARK: - Dependencies

    private let socketClient: SocketClientProtocol

    // MARK: - Publishers

    private let messageSubject = PassthroughSubject<MessageEntity, Never>()
    private let whisperSubject = PassthroughSubject<MessageEntity, Never>()
    private let typingSubject = PassthroughSubject<(roomId: String, userId: String, isTyping: Bool), Never>()
    private let userStatusSubject = PassthroughSubject<(userId: String, status: UserStatus), Never>()

    var messagePublisher: AnyPublisher<MessageEntity, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    var whisperPublisher: AnyPublisher<MessageEntity, Never> {
        whisperSubject.eraseToAnyPublisher()
    }

    var typingPublisher: AnyPublisher<(roomId: String, userId: String, isTyping: Bool), Never> {
        typingSubject.eraseToAnyPublisher()
    }

    var userStatusPublisher: AnyPublisher<(userId: String, status: UserStatus), Never> {
        userStatusSubject.eraseToAnyPublisher()
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
        case .newMessage(let roomId, let senderId, let senderName, let content, let timestamp):
            let message = MessageEntity(
                id: UUID().uuidString,
                roomId: roomId,
                senderId: senderId,
                senderName: senderName,
                content: content,
                type: .normal,
                targetUserId: nil,
                timestamp: DateParser.parse(timestamp)
            )
            messageSubject.send(message)

        case .whisper(let senderId, let senderName, let content, let timestamp):
            let message = MessageEntity(
                id: UUID().uuidString,
                roomId: "",
                senderId: senderId,
                senderName: senderName,
                content: content,
                type: .whisper,
                targetUserId: SessionManager.shared.currentUserId,
                timestamp: DateParser.parse(timestamp)
            )
            whisperSubject.send(message)

        case .typing(let roomId, let userId, let isTyping):
            typingSubject.send((roomId, userId, isTyping))

        case .statusChanged(let userId, let newStatus):
            userStatusSubject.send((userId, newStatus))

        default:
            break
        }
    }

    // MARK: - Methods

    func sendMessage(roomId: String, content: String) async throws {
        let request = Request.sendMessage(roomId: roomId, content: content)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.messageSendFailed(response.message)
        }
    }

    func sendWhisper(targetUserId: String, content: String) async throws {
        let request = Request.sendWhisper(targetUserId: targetUserId, content: content)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            if let errorCode = response.errorCode,
               let code = ProtocolErrorCode(rawValue: errorCode) {
                throw ChatError.from(protocolError: code)
            }
            throw ChatError.whisperFailed(response.message)
        }
    }

    func sendTyping(roomId: String, isTyping: Bool) {
        let request = Request.typing(roomId: roomId, isTyping: isTyping)
        try? socketClient.send(request.rawString)
    }

    func changeStatus(_ status: UserStatus) async throws {
        let request = Request.changeStatus(status)
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.unknown(response.message)
        }
    }

    func getUserList() async throws -> [UserEntity] {
        let request = Request.getUserList()
        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.unknown(response.message)
        }

        return MessageParser.parseUserList(from: response)
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
}
