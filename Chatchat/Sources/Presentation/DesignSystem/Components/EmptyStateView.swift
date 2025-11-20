//
//  EmptyStateView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct EmptyStateView: View {
    
    // MARK: - Properties
    
    let icon: String
    let title: String
    var message: String? = nil
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray3)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.head01)
                    .foregroundColor(.textPrimary)

                if let message = message {
                    Text(message)
                        .font(.body04)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let buttonTitle = buttonTitle, let action = buttonAction {
                PrimaryButton(buttonTitle, style: .outlined, action: action)
                    .frame(width: 160)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
