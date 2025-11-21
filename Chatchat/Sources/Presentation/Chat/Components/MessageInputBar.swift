//
//  MessageInputBar.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

/// 메시지 입력 바 컴포넌트
struct MessageInputBar: View {

    @Binding var text: String
    var placeholder: String = "메시지를 입력하세요"
    var whisperTarget: UserEntity? = nil
    var onSend: () -> Void
    var onClearWhisper: (() -> Void)? = nil
    var onTextChanged: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if let target = whisperTarget {
                whisperModeBar(target: target)
            }

            HStack(spacing: Spacing.xs) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.body04)
                    .lineLimit(1...4)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(CornerRadius.large)
                    .focused($isFocused)
                    .onChange(of: text) { _, _ in
                        onTextChanged?()
                    }

                Button {
                    onSend()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: ComponentSize.iconMedium))
                        .foregroundColor(canSend ? .white0 : .gray4)
                        .frame(width: 40, height: 40)
                        .background(canSend ? Color.mainColor : Color.gray2)
                        .cornerRadius(CornerRadius.full)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(Color.backgroundPrimary)
        }
    }

    // MARK: - Whisper Mode Bar

    private func whisperModeBar(target: UserEntity) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 12))
                .foregroundColor(.orange2)

            Text("\(target.name)님에게 귓속말")
                .font(.caption01)
                .foregroundColor(.orange3)

            Spacer()

            Button {
                onClearWhisper?()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray4)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Color.orange1)
    }

    // MARK: - Computed Properties

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
