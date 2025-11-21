//
//  ChatRoomViewModel.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/21/25.
//

import Foundation
import Combine

@MainActor
final class ChatRoomViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var messages: [MessageEntity] = []
    @Published var users: [UserEntity] = []
    @Published var messageText: String = ""
    @Published var whisperTarget: UserEntity? = nil
    @Published var typingUsers: Set<String> = []
    @Published var state: ViewState<Void> = .idle
    @Published var showUserList: Bool = false

    // MARK: - Properties

    let room: ChatRoomEntity

    var isWhisperMode: Bool {
        whisperTarget != nil
    }

    var currentUserId: String {
        SessionManager.shared.currentUserId ?? ""
    }

    var currentUserName: String {
        SessionManager.shared.currentUserName ?? ""
    }

    var typingUsersText: String? {
        guard !typingUsers.isEmpty else { return nil }
        let names = typingUsers.prefix(3).joined(separator: ", ")
        if typingUsers.count > 3 {
            return "\(names) 외 \(typingUsers.count - 3)명이 입력 중..."
        }
        return "\(names)님이 입력 중..."
    }

    var inputPlaceholder: String {
        if let target = whisperTarget {
            return "\(target.name)님에게 귓속말..."
        }
        return "메시지를 입력하세요"
    }

    // MARK: - Dependencies

    private let sendMessageUseCase: SendMessageUseCaseProtocol
    private let sendWhisperUseCase: SendWhisperUseCaseProtocol
    private let observeMessagesUseCase: ObserveMessagesUseCaseProtocol
    private let observeWhispersUseCase: ObserveWhispersUseCaseProtocol
    private let getRoomUsersUseCase: GetRoomUsersUseCaseProtocol
    private let leaveRoomUseCase: LeaveRoomUseCaseProtocol
    private let chatRepository: ChatRepositoryProtocol
    private let roomRepository: RoomRepositoryProtocol

    private var cancellables = Set<AnyCancellable>()
    private var typingTimer: Timer?
    private var isTyping: Bool = false

    // MARK: - Initialization

    init(
        room: ChatRoomEntity,
        sendMessageUseCase: SendMessageUseCaseProtocol,
        sendWhisperUseCase: SendWhisperUseCaseProtocol,
        observeMessagesUseCase: ObserveMessagesUseCaseProtocol,
        observeWhispersUseCase: ObserveWhispersUseCaseProtocol,
        getRoomUsersUseCase: GetRoomUsersUseCaseProtocol,
        leaveRoomUseCase: LeaveRoomUseCaseProtocol,
        chatRepository: ChatRepositoryProtocol,
        roomRepository: RoomRepositoryProtocol
    ) {
        self.room = room
        self.sendMessageUseCase = sendMessageUseCase
        self.sendWhisperUseCase = sendWhisperUseCase
        self.observeMessagesUseCase = observeMessagesUseCase
        self.observeWhispersUseCase = observeWhispersUseCase
        self.getRoomUsersUseCase = getRoomUsersUseCase
        self.leaveRoomUseCase = leaveRoomUseCase
        self.chatRepository = chatRepository
        self.roomRepository = roomRepository

        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        // 메시지 수신 (현재 방만 필터링)
        observeMessagesUseCase.execute(roomId: room.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleNewMessage(message)
            }
            .store(in: &cancellables)

        // 귓속말 수신
        observeWhispersUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleNewMessage(message)
            }
            .store(in: &cancellables)

        // 타이핑 상태
        chatRepository.typingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (roomId, userId, isTyping) in
                self?.handleTypingStatus(roomId: roomId, userId: userId, isTyping: isTyping)
            }
            .store(in: &cancellables)

        // 사용자 입장
        roomRepository.userJoinedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (roomId, user) in
                self?.handleUserJoined(roomId: roomId, user: user)
            }
            .store(in: &cancellables)

        // 사용자 퇴장
        roomRepository.userLeftPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (roomId, userId) in
                self?.handleUserLeft(roomId: roomId, userId: userId)
            }
            .store(in: &cancellables)

        // 사용자 상태 변경
        chatRepository.userStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (userId, status) in
                self?.handleUserStatusChanged(userId: userId, status: status)
            }
            .store(in: &cancellables)
    }

    // MARK: - Event Handlers

    private func handleNewMessage(_ message: MessageEntity) {
        // 중복 체크
        guard !messages.contains(where: { $0.id == message.id }) else { return }

        // SYSTEM 메시지는 무시 (handleUserJoined/handleUserLeft에서 안내 배너로 처리)
        guard message.senderId.uppercased() != "SYSTEM" else { return }

        messages.append(message)
    }

    private func handleTypingStatus(roomId: String, userId: String, isTyping: Bool) {
        guard roomId == room.id, userId != currentUserId else { return }

        if isTyping {
            typingUsers.insert(userId)
        } else {
            typingUsers.remove(userId)
        }
    }

    private func handleUserJoined(roomId: String, user: UserEntity) {
        guard roomId == room.id else { return }

        // 사용자 목록에 추가
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
        }

        // 시스템 메시지 추가
        let systemMessage = MessageEntity.userJoined(roomId: roomId, userName: user.name)
        messages.append(systemMessage)
    }

    private func handleUserLeft(roomId: String, userId: String) {
        guard roomId == room.id else { return }

        // 퇴장한 사용자 이름 찾기
        let userName = users.first(where: { $0.id == userId })?.name ?? userId

        // 사용자 목록에서 제거
        users.removeAll { $0.id == userId }

        // 타이핑 목록에서 제거
        typingUsers.remove(userId)

        // 귓속말 대상이었다면 해제
        if whisperTarget?.id == userId {
            whisperTarget = nil
        }

        // 시스템 메시지 추가
        let systemMessage = MessageEntity.userLeft(roomId: roomId, userName: userName)
        messages.append(systemMessage)
    }

    private func handleUserStatusChanged(userId: String, status: UserStatus) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].status = status
        }
    }

    // MARK: - Actions

    func onAppear() {
        loadRoomUsers()
    }

    func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        messageText = ""
        stopTyping()

        Task {
            do {
                if let target = whisperTarget {
                    // 귓속말 전송
                    try await sendWhisperUseCase.execute(
                        targetUserId: target.id,
                        content: content
                    )

                    // 보낸 귓속말을 로컬에 추가
                    let sentMessage = MessageEntity(
                        roomId: room.id,
                        senderId: currentUserId,
                        senderName: currentUserName,
                        content: content,
                        type: .whisper,
                        targetUserId: target.id
                    )
                    messages.append(sentMessage)

                    clearWhisperMode()
                } else {
                    // 일반 메시지 전송
                    try await sendMessageUseCase.execute(roomId: room.id, content: content)
                }
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func onTextChanged() {
        guard !messageText.isEmpty else {
            stopTyping()
            return
        }

        if !isTyping {
            isTyping = true
            sendTypingStatus(true)
        }

        // 디바운스: 2초 후 타이핑 중지
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.stopTyping()
            }
        }
    }

    private func stopTyping() {
        guard isTyping else { return }
        isTyping = false
        typingTimer?.invalidate()
        typingTimer = nil
        sendTypingStatus(false)
    }

    private func sendTypingStatus(_ typing: Bool) {
        chatRepository.sendTyping(roomId: room.id, isTyping: typing)
    }

    func setWhisperTarget(_ user: UserEntity) {
        guard user.id != currentUserId else { return }
        whisperTarget = user
    }

    func clearWhisperMode() {
        whisperTarget = nil
    }

    func loadRoomUsers() {
        Task {
            do {
                users = try await getRoomUsersUseCase.execute(roomId: room.id)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func leaveRoom() async throws {
        guard !room.isLobby else {
            throw ChatError.cannotLeaveLobby
        }
        try await leaveRoomUseCase.execute(roomId: room.id)
    }

    func clearError() {
        if state.isError {
            state = .idle
        }
    }

    // MARK: - Cleanup

    deinit {
        typingTimer?.invalidate()
    }
}
