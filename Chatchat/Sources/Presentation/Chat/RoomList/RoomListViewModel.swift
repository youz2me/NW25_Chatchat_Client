//
//  RoomListViewModel.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/21/25.
//

import Foundation
import Combine

@MainActor
final class RoomListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var rooms: [ChatRoomEntity] = []
    @Published var state: ViewState<Void> = .idle
    @Published var showCreateRoomSheet: Bool = false
    @Published var newRoomName: String = ""
    @Published var selectedRoom: ChatRoomEntity? = nil
    @Published var showLogoutAlert: Bool = false

    // MARK: - Computed Properties

    var currentUserName: String {
        SessionManager.shared.currentUserName ?? "사용자"
    }

    var canCreateRoom: Bool {
        !newRoomName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !state.isLoading
    }

    var sortedRooms: [ChatRoomEntity] {
        // 로비를 맨 위에, 나머지는 이름순
        rooms.sorted { lhs, rhs in
            if lhs.isLobby { return true }
            if rhs.isLobby { return false }
            return lhs.name < rhs.name
        }
    }

    // MARK: - Dependencies

    private let getRoomListUseCase: GetRoomListUseCaseProtocol
    private let createRoomUseCase: CreateRoomUseCaseProtocol
    private let joinRoomUseCase: JoinRoomUseCaseProtocol
    private let observeRoomEventsUseCase: ObserveRoomEventsUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        getRoomListUseCase: GetRoomListUseCaseProtocol,
        createRoomUseCase: CreateRoomUseCaseProtocol,
        joinRoomUseCase: JoinRoomUseCaseProtocol,
        observeRoomEventsUseCase: ObserveRoomEventsUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol
    ) {
        self.getRoomListUseCase = getRoomListUseCase
        self.createRoomUseCase = createRoomUseCase
        self.joinRoomUseCase = joinRoomUseCase
        self.observeRoomEventsUseCase = observeRoomEventsUseCase
        self.logoutUseCase = logoutUseCase

        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        // 새 채팅방 생성 이벤트
        observeRoomEventsUseCase.observeRoomCreated()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] room in
                self?.handleRoomCreated(room)
            }
            .store(in: &cancellables)

        // 사용자 입장/퇴장으로 인한 인원수 변경은
        // 실시간 반영이 어려우므로 refresh로 처리
    }

    private func handleRoomCreated(_ room: ChatRoomEntity) {
        // 중복 체크 후 추가
        guard !rooms.contains(where: { $0.id == room.id }) else { return }
        rooms.append(room)
    }

    // MARK: - Actions

    func onAppear() {
        if rooms.isEmpty {
            loadRooms()
        }
    }

    func loadRooms() {
        state = .loading

        Task {
            do {
                rooms = try await getRoomListUseCase.execute()
                state = .success(())
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func refresh() {
        loadRooms()
    }

    func createRoom() {
        let name = newRoomName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        state = .loading

        Task {
            do {
                let room = try await createRoomUseCase.execute(name: name)

                // 로컬 목록에 추가
                if !rooms.contains(where: { $0.id == room.id }) {
                    rooms.append(room)
                }

                // 폼 초기화
                newRoomName = ""
                showCreateRoomSheet = false
                state = .success(())

                // 생성한 방으로 입장
                selectRoom(room)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func selectRoom(_ room: ChatRoomEntity) {
        state = .loading

        Task {
            do {
                try await joinRoomUseCase.execute(roomId: room.id)
                selectedRoom = room
                state = .success(())
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func logout() {
        state = .loading

        Task {
            do {
                try await logoutUseCase.execute()
                state = .success(())

                // 로그아웃 알림
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func dismissCreateSheet() {
        showCreateRoomSheet = false
        newRoomName = ""
    }

    func clearSelectedRoom() {
        selectedRoom = nil
    }

    func clearError() {
        if state.isError {
            state = .idle
        }
    }
}
