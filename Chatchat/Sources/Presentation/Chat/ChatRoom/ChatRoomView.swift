//
//  ChatRoomView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/21/25.
//

import SwiftUI

struct ChatRoomView: View {

    @StateObject private var viewModel: ChatRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLeaveAlert: Bool = false

    init(viewModel: ChatRoomViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            messageListView

            if let typingText = viewModel.typingUsersText {
                TypingIndicator(text: typingText)
            }

            MessageInputBar(
                text: $viewModel.messageText,
                placeholder: viewModel.inputPlaceholder,
                whisperTarget: viewModel.whisperTarget,
                onSend: viewModel.sendMessage,
                onClearWhisper: viewModel.clearWhisperMode,
                onTextChanged: viewModel.onTextChanged
            )
        }
        .background(Color.backgroundSecondary)
        .navigationTitle(viewModel.room.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.xs) {
                    userListButton

                    if !viewModel.room.isLobby {
                        leaveButton
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showUserList) {
            userListSheet
        }
        .alert("채팅방 나가기", isPresented: $showLeaveAlert) {
            Button("취소", role: .cancel) {}
            Button("나가기", role: .destructive) {
                leaveRoom()
            }
        } message: {
            Text("정말 이 채팅방을 나가시겠습니까?")
        }
        .errorAlert($viewModel.state, onDismiss: viewModel.clearError)
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Navigation Buttons

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "chevron.left")
                Text("목록")
            }
            .font(.body03)
            .foregroundColor(.mainColor)
        }
    }

    private var userListButton: some View {
        Button {
            viewModel.showUserList = true
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14))
                Text("\(viewModel.users.count)")
                    .font(.caption01)
            }
            .foregroundColor(.textSecondary)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.full)
        }
    }

    private var leaveButton: some View {
        Button {
            showLeaveAlert = true
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 16))
                .foregroundColor(.error)
        }
    }

    // MARK: - Message List

    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.xs) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == viewModel.currentUserId
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    // MARK: - User List Sheet

    private var userListSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sortedUsers) { user in
                        VStack(spacing: 0) {
                            UserListItem(
                                user: user,
                                isCurrentUser: user.id == viewModel.currentUserId,
                                onWhisper: user.id != viewModel.currentUserId ? {
                                    viewModel.setWhisperTarget(user)
                                    viewModel.showUserList = false
                                } : nil
                            )

                            Divider()
                                .padding(.leading, Spacing.md + ComponentSize.avatarMedium + Spacing.sm)
                        }
                    }
                }
            }
            .navigationTitle("참여자 (\(viewModel.users.count)명)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        viewModel.showUserList = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var sortedUsers: [UserEntity] {
        viewModel.users.sorted { lhs, rhs in
            // 현재 사용자를 맨 위에
            if lhs.id == viewModel.currentUserId { return true }
            if rhs.id == viewModel.currentUserId { return false }

            // 온라인 상태 우선
            let statusOrder: [UserStatus] = [.online, .away, .busy, .offline]
            let lhsOrder = statusOrder.firstIndex(of: lhs.status) ?? 4
            let rhsOrder = statusOrder.firstIndex(of: rhs.status) ?? 4

            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }

            // 이름순
            return lhs.name < rhs.name
        }
    }

    // MARK: - Actions

    private func leaveRoom() {
        Task {
            do {
                try await viewModel.leaveRoom()
                dismiss()
            } catch {
                viewModel.state = .error(error.localizedDescription)
            }
        }
    }
}
