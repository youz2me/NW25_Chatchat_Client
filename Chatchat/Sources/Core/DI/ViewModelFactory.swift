//
//  ViewModelFactory.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation
import SwiftUI

/// ViewModel 팩토리
/// - ViewModel 생성 시 필요한 의존성 주입
@MainActor
final class ViewModelFactory {
    private let container: DependencyContainer

    init(container: DependencyContainer = DIContainer.shared) {
        self.container = container
    }

    // MARK: - Auth ViewModels

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            loginUseCase: container.resolve(LoginUseCaseProtocol.self)
        )
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerUseCase: container.resolve(RegisterUseCaseProtocol.self)
        )
    }

    func makeFindPasswordViewModel() -> FindPasswordViewModel {
        FindPasswordViewModel(
            findPasswordUseCase: container.resolve(FindPasswordUseCaseProtocol.self)
        )
    }

    // MARK: - Chat ViewModels

    func makeChatRoomViewModel(room: ChatRoomEntity) -> ChatRoomViewModel {
        ChatRoomViewModel(
            room: room,
            sendMessageUseCase: container.resolve(SendMessageUseCaseProtocol.self),
            sendWhisperUseCase: container.resolve(SendWhisperUseCaseProtocol.self),
            observeMessagesUseCase: container.resolve(ObserveMessagesUseCaseProtocol.self),
            observeWhispersUseCase: container.resolve(ObserveWhispersUseCaseProtocol.self),
            getRoomUsersUseCase: container.resolve(GetRoomUsersUseCaseProtocol.self),
            leaveRoomUseCase: container.resolve(LeaveRoomUseCaseProtocol.self),
            chatRepository: container.resolve(ChatRepositoryProtocol.self),
            roomRepository: container.resolve(RoomRepositoryProtocol.self)
        )
    }

    func makeRoomListViewModel() -> RoomListViewModel {
        RoomListViewModel(
            getRoomListUseCase: container.resolve(GetRoomListUseCaseProtocol.self),
            createRoomUseCase: container.resolve(CreateRoomUseCaseProtocol.self),
            joinRoomUseCase: container.resolve(JoinRoomUseCaseProtocol.self),
            observeRoomEventsUseCase: container.resolve(ObserveRoomEventsUseCaseProtocol.self),
            logoutUseCase: container.resolve(LogoutUseCaseProtocol.self)
        )
    }
}

// MARK: - Environment Key

private struct ViewModelFactoryKey: @MainActor EnvironmentKey {
    @MainActor static let defaultValue = ViewModelFactory()
}

extension EnvironmentValues {
    @MainActor
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }
}
