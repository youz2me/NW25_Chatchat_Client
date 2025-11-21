//
//  RoomListItem.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

/// 채팅방 목록 아이템 컴포넌트
struct RoomListItem: View {

    let room: ChatRoomEntity
    var isCurrentRoom: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: Spacing.sm) {
                roomIcon

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xs) {
                        Text(room.name)
                            .font(.body01)
                            .foregroundColor(.textPrimary)

                        if room.isLobby {
                            lobbyBadge
                        }
                    }

                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.textTertiary)

                        Text("\(room.userCount)명 참여 중")
                            .font(.caption02)
                            .foregroundColor(.textTertiary)
                    }
                }

                Spacer()

                if isCurrentRoom {
                    currentRoomBadge
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray3)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isCurrentRoom ? Color.green1.opacity(0.3) : Color.backgroundPrimary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Current Room Badge

    private var currentRoomBadge: some View {
        Text("현재 참여 중")
            .font(.caption02)
            .foregroundColor(.mainColor)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 4)
            .background(Color.green1)
            .cornerRadius(CornerRadius.small)
    }

    // MARK: - Subviews

    private var roomIcon: some View {
        ZStack {
            Circle()
                .fill(room.isLobby ? Color.green1 : Color.gray1)
                .frame(width: ComponentSize.avatarMedium, height: ComponentSize.avatarMedium)

            Image(systemName: room.isLobby ? "house.fill" : "bubble.left.and.bubble.right.fill")
                .font(.system(size: ComponentSize.iconSmall))
                .foregroundColor(room.isLobby ? .mainColor : .gray5)
        }
    }

    private var lobbyBadge: some View {
        Text("로비")
            .font(.caption02)
            .foregroundColor(.mainColor)
            .padding(.horizontal, Spacing.xxs)
            .padding(.vertical, 2)
            .background(Color.green1)
            .cornerRadius(CornerRadius.small)
    }
}
