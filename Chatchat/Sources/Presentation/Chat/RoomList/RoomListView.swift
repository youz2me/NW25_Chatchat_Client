//
//  RoomListView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/21/25.
//

import SwiftUI

struct RoomListView: View {

    @StateObject private var viewModel: RoomListViewModel
    @State private var navigationPath = NavigationPath()

    init(viewModel: RoomListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                headerSection

                if viewModel.state.isLoading && viewModel.rooms.isEmpty {
                    LoadingView(message: "채팅방 목록을 불러오는 중...")
                } else if viewModel.rooms.isEmpty {
                    emptyStateView
                } else {
                    roomListContent
                }
            }
            .background(Color.backgroundSecondary)
            .navigationBarHidden(true)
            .navigationDestination(for: ChatRoomEntity.self) { room in
                ChatRoomView(
                    viewModel: makeChatRoomViewModel(room: room)
                )
            }
            .sheet(isPresented: $viewModel.showCreateRoomSheet) {
                createRoomSheet
            }
            .alert("로그아웃", isPresented: $viewModel.showLogoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("정말 로그아웃 하시겠습니까?")
            }
            .errorAlert($viewModel.state, onDismiss: viewModel.clearError)
            .onAppear {
                viewModel.onAppear()
            }
            .onChange(of: viewModel.selectedRoom) { _, selectedRoom in
                if let room = selectedRoom {
                    navigationPath.append(room)
                    viewModel.clearSelectedRoom()
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("채팅")
                        .font(.title01)
                        .foregroundColor(.textPrimary)

                    Text("\(viewModel.currentUserName)님, 환영합니다")
                        .font(.body04)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Menu {
                    Button {
                        viewModel.showCreateRoomSheet = true
                    } label: {
                        Label("새 채팅방", systemImage: "plus.bubble")
                    }

                    Button(role: .destructive) {
                        viewModel.showLogoutAlert = true
                    } label: {
                        Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.backgroundPrimary)

            Divider()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "bubble.left.and.bubble.right",
            title: "채팅방이 없습니다",
            message: "새로운 채팅방을 만들어보세요",
            buttonTitle: "방 만들기"
        ) {
            viewModel.showCreateRoomSheet = true
        }
    }

    // MARK: - Room List Content

    private var roomListContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sortedRooms) { room in
                    VStack(spacing: 0) {
                        RoomListItem(
                            room: room,
                            isCurrentRoom: room.isLobby
                        ) {
                            viewModel.selectRoom(room)
                        }

                        Divider()
                            .padding(.leading, Spacing.lg + ComponentSize.avatarMedium + Spacing.sm)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .cornerRadius(CornerRadius.large)
            .padding(Spacing.md)
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Create Room Sheet

    private var createRoomSheet: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("채팅방 이름")
                        .font(.label01)
                        .foregroundColor(.textPrimary)

                    AppTextField(
                        placeholder: "채팅방 이름을 입력하세요",
                        text: $viewModel.newRoomName
                    )
                }

                PrimaryButton(
                    "만들기",
                    isLoading: viewModel.state.isLoading,
                    isEnabled: viewModel.canCreateRoom
                ) {
                    viewModel.createRoom()
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .navigationTitle("새 채팅방")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        viewModel.dismissCreateSheet()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Factory Methods

    @MainActor
    private func makeChatRoomViewModel(room: ChatRoomEntity) -> ChatRoomViewModel {
        ViewModelFactory().makeChatRoomViewModel(room: room)
    }
}
