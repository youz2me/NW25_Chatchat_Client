//
//  AppTextField.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct AppTextField: View {
    
    // MARK: - Properties
    
    let placeholder: String
    
    @Binding var text: String
    
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    var onSubmit: (() -> Void)? = nil
    

    @FocusState private var isFocused: Bool
    @State private var isSecureVisible: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xs) {
                textFieldContent
                    .font(.body02)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .onSubmit {
                        onSubmit?()
                    }

                if isSecure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray4)
                            .frame(width: ComponentSize.iconMedium, height: ComponentSize.iconMedium)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: ComponentSize.textFieldHeight)
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.caption02)
                    .foregroundColor(.error)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var textFieldContent: some View {
        if isSecure && !isSecureVisible {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }

    // MARK: - Computed Properties

    private var borderColor: Color {
        if errorMessage != nil {
            return .error
        }
        return isFocused ? .borderFocused : .clear
    }
}
