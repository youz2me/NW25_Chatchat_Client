//
//  ErrorAlert.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    
    // MARK: - Properties
    
    @Binding var errorMessage: String?
    var title: String = "오류"
    var buttonTitle: String = "확인"
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: showAlert) {
                Button(buttonTitle, role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let message = errorMessage {
                    Text(message)
                }
            }
    }

    private var showAlert: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }
}

extension View {
    func errorAlert(
        _ errorMessage: Binding<String?>,
        title: String = "오류",
        buttonTitle: String = "확인"
    ) -> some View {
        modifier(ErrorAlertModifier(
            errorMessage: errorMessage,
            title: title,
            buttonTitle: buttonTitle
        ))
    }
}

/// ViewState 기반 에러 알림 모디파이어
struct ViewStateErrorAlertModifier<T>: ViewModifier {

    @Binding var state: ViewState<T>
    var title: String = "오류"
    var buttonTitle: String = "확인"
    var onDismiss: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: showAlert) {
                Button(buttonTitle, role: .cancel) {
                    state = .idle
                    onDismiss?()
                }
            } message: {
                if let message = state.errorMessage {
                    Text(message)
                }
            }
    }

    private var showAlert: Binding<Bool> {
        Binding(
            get: { state.isError },
            set: { if !$0 { state = .idle } }
        )
    }
}

extension View {
    func errorAlert<T>(
        _ state: Binding<ViewState<T>>,
        title: String = "오류",
        buttonTitle: String = "확인",
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ViewStateErrorAlertModifier(
            state: state,
            title: title,
            buttonTitle: buttonTitle,
            onDismiss: onDismiss
        ))
    }
}
