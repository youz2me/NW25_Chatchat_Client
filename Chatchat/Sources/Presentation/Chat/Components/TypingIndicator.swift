//
//  TypingIndicator.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

/// 타이핑 표시 컴포넌트
struct TypingIndicator: View {

    let text: String

    @State private var dotCount: Int = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Text(text)
                .font(.caption02)
                .foregroundColor(.textSecondary)

            HStack(spacing: 2) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray4)
                        .frame(width: 4, height: 4)
                        .opacity(dotCount > index ? 1 : 0.3)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xxs)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}
