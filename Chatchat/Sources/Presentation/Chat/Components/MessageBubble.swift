//
//  MessageBubble.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

/// 메시지 버블 컴포넌트
struct MessageBubble: View {

    let message: MessageEntity
    let isCurrentUser: Bool

    var body: some View {
        switch message.type {
        case .system:
            systemMessageView
        case .normal, .whisper:
            chatMessageView
        }
    }

    // MARK: - System Message

    private var systemMessageView: some View {
        HStack {
            Spacer()
            Text(message.content)
                .font(.caption02)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(Color.gray1)
                .cornerRadius(CornerRadius.full)
            Spacer()
        }
        .padding(.vertical, Spacing.xxs)
    }

    // MARK: - Chat Message

    private var chatMessageView: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            if isCurrentUser {
                Spacer(minLength: Spacing.huge)
                timeLabel
                bubbleContent
            } else {
                bubbleContent
                timeLabel
                Spacer(minLength: Spacing.huge)
            }
        }
    }

    private var bubbleContent: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: Spacing.xxs) {
            if !isCurrentUser {
                HStack(spacing: Spacing.xxs) {
                    Text(message.senderName)
                        .font(.caption01)
                        .foregroundColor(.textSecondary)

                    if message.type == .whisper {
                        Text("귓속말")
                            .font(.caption02)
                            .foregroundColor(.white0)
                            .padding(.horizontal, Spacing.xxs)
                            .padding(.vertical, 2)
                            .background(Color.orange2)
                            .cornerRadius(CornerRadius.small)
                    }
                }
            }

            HStack {
                if isCurrentUser && message.type == .whisper {
                    whisperBadge
                }

                Text(message.content)
                    .font(.body04)
                    .foregroundColor(bubbleTextColor)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(bubbleBackgroundColor)
                    .cornerRadius(CornerRadius.large)
            }
        }
    }

    private var timeLabel: some View {
        Text(formattedTime)
            .font(.caption02)
            .foregroundColor(.textTertiary)
    }

    private var whisperBadge: some View {
        Text("귓속말")
            .font(.caption02)
            .foregroundColor(.white0)
            .padding(.horizontal, Spacing.xxs)
            .padding(.vertical, 2)
            .background(Color.orange2)
            .cornerRadius(CornerRadius.small)
    }

    // MARK: - Computed Properties

    private var bubbleBackgroundColor: Color {
        if message.type == .whisper {
            return isCurrentUser ? Color.orange1 : Color.orange1
        }
        return isCurrentUser ? .mainColor : .gray1
    }

    private var bubbleTextColor: Color {
        if message.type == .whisper {
            return .textPrimary
        }
        return isCurrentUser ? .white0 : .textPrimary
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: message.timestamp)
    }
}
