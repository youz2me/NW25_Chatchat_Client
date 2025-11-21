//
//  UserListItem.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

/// 사용자 목록 아이템 컴포넌트
struct UserListItem: View {

    let user: UserEntity
    var isCurrentUser: Bool = false
    var onWhisper: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            UserAvatar(
                name: user.name,
                status: user.status,
                size: .medium
            )

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xxs) {
                    Text(user.name)
                        .font(.body03)
                        .foregroundColor(.textPrimary)

                    if isCurrentUser {
                        Text("(나)")
                            .font(.caption02)
                            .foregroundColor(.mainColor)
                    }
                }

                Text(statusText)
                    .font(.caption02)
                    .foregroundColor(statusColor)
            }

            Spacer()

            if !isCurrentUser, let onWhisper = onWhisper {
                Button {
                    onWhisper()
                } label: {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: ComponentSize.iconSmall))
                        .foregroundColor(.mainColor)
                        .frame(width: ComponentSize.avatarSmall, height: ComponentSize.avatarSmall)
                        .background(Color.green1)
                        .cornerRadius(CornerRadius.medium)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.backgroundPrimary)
    }

    // MARK: - Computed Properties

    private var statusText: String {
        switch user.status {
        case .online: return "온라인"
        case .away: return "자리 비움"
        case .busy: return "바쁨"
        case .offline: return "오프라인"
        }
    }

    private var statusColor: Color {
        switch user.status {
        case .online: return .mainColor
        case .away: return .orange2
        case .busy: return .error
        case .offline: return .gray4
        }
    }
}
