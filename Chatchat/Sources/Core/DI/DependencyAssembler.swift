//
//  DependencyAssembler.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

protocol DependencyAssembler {
    func assemble(to container: DependencyContainer)
}

// MARK: - App Assembler

final class AppAssembler {
    static func assemble() {
        let container = DIContainer.shared

        container.register(assemblers: [
            NetworkAssembler(),
            RepositoryAssembler(),
            UseCaseAssembler()
        ])
    }
}

// MARK: - Network Assembler

struct NetworkAssembler: DependencyAssembler {
    func assemble(to container: DependencyContainer) {
        let socketClient = SocketClient()
        container.register(socketClient, for: SocketClientProtocol.self)
    }
}

// MARK: - Repository Assembler

struct RepositoryAssembler: DependencyAssembler {
    func assemble(to container: DependencyContainer) {
        let socketClient = container.resolve(SocketClientProtocol.self)
        
        let authRepository = AuthRepository(socketClient: socketClient)
        container.register(authRepository, for: AuthRepositoryProtocol.self)
        
        let chatRepository = ChatRepository(socketClient: socketClient)
        container.register(chatRepository, for: ChatRepositoryProtocol.self)
        
        let roomRepository = RoomRepository(socketClient: socketClient)
        container.register(roomRepository, for: RoomRepositoryProtocol.self)
    }
}

// MARK: - UseCase Assembler

struct UseCaseAssembler: DependencyAssembler {
    func assemble(to container: DependencyContainer) {
        let socketClient = container.resolve(SocketClientProtocol.self)
        let authRepository = container.resolve(AuthRepositoryProtocol.self)
        let chatRepository = container.resolve(ChatRepositoryProtocol.self)
        let roomRepository = container.resolve(RoomRepositoryProtocol.self)
        
        container.register(
            LoginUseCase(authRepository: authRepository, socketClient: socketClient),
            for: LoginUseCaseProtocol.self
        )
        
        container.register(
            RegisterUseCase(authRepository: authRepository, socketClient: socketClient),
            for: RegisterUseCaseProtocol.self
        )
        
        container.register(
            FindPasswordUseCase(authRepository: authRepository, socketClient: socketClient),
            for: FindPasswordUseCaseProtocol.self
        )
        
        container.register(
            LogoutUseCase(authRepository: authRepository),
            for: LogoutUseCaseProtocol.self
        )
        
        container.register(
            SendMessageUseCase(chatRepository: chatRepository, roomRepository: roomRepository),
            for: SendMessageUseCaseProtocol.self
        )

        container.register(
            SendWhisperUseCase(chatRepository: chatRepository),
            for: SendWhisperUseCaseProtocol.self
        )

        container.register(
            ObserveMessagesUseCase(chatRepository: chatRepository),
            for: ObserveMessagesUseCaseProtocol.self
        )

        container.register(
            ObserveWhispersUseCase(chatRepository: chatRepository),
            for: ObserveWhispersUseCaseProtocol.self
        )

        container.register(
            ChangeStatusUseCase(chatRepository: chatRepository),
            for: ChangeStatusUseCaseProtocol.self
        )

        container.register(
            GetUserListUseCase(chatRepository: chatRepository),
            for: GetUserListUseCaseProtocol.self
        )
        
        container.register(
            CreateRoomUseCase(roomRepository: roomRepository),
            for: CreateRoomUseCaseProtocol.self
        )

        container.register(
            JoinRoomUseCase(roomRepository: roomRepository),
            for: JoinRoomUseCaseProtocol.self
        )

        container.register(
            LeaveRoomUseCase(roomRepository: roomRepository),
            for: LeaveRoomUseCaseProtocol.self
        )

        container.register(
            GetRoomListUseCase(roomRepository: roomRepository),
            for: GetRoomListUseCaseProtocol.self
        )

        container.register(
            GetRoomUsersUseCase(roomRepository: roomRepository),
            for: GetRoomUsersUseCaseProtocol.self
        )

        container.register(
            ObserveRoomEventsUseCase(roomRepository: roomRepository),
            for: ObserveRoomEventsUseCaseProtocol.self
        )
    }
}
