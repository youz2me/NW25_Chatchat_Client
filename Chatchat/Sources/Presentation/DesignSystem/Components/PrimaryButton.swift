//
//  PrimaryButton.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct PrimaryButton: View {

    // MARK: - Properties

    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var style: ButtonStyle = .filled

    enum ButtonStyle {
        case filled
        case outlined
        case text
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                }

                Text(title)
                    .font(.label01)
            }
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSize.buttonLarge)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(borderColor, lineWidth: style == .outlined ? 1 : 0)
            )
        }
        .disabled(!isEnabled || isLoading)
    }

    // MARK: - Computed Properties

    private var textColor: Color {
        switch style {
        case .filled:
            return .white0
        case .outlined, .text:
            return isEnabled ? .mainColor : .gray3
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return isEnabled ? .mainColor : .gray3
        case .outlined, .text:
            return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .outlined:
            return isEnabled ? .mainColor : .gray3
        case .filled, .text:
            return .clear
        }
    }
}

// MARK: - Convenience Initializers

extension PrimaryButton {
    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        style: ButtonStyle = .filled,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.style = style
        self.action = action
    }
}
