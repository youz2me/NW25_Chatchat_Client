//
//  LoadingView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct LoadingView: View {
    
    // MARK: - Properties

    var message: String? = nil
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .mainColor))
                .scaleEffect(1.2)

            if let message = message {
                Text(message)
                    .font(.body04)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary.opacity(0.8))
    }
}

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool
    var message: String? = nil

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)

            if isLoading {
                LoadingView(message: message)
            }
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingOverlay(isLoading: isLoading, message: message))
    }
}
