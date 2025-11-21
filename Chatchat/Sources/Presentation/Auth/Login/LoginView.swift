//
//  LoginView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var showRegister: Bool = false
    @State private var showFindPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showConnectionError: Bool = false

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                connectionStatusBar

                Spacer()

                headerSection

                Spacer()
                    .frame(height: Spacing.xxxl)

                formSection

                Spacer()

                bottomSection
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
            .background(Color.backgroundPrimary)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: makeRegisterViewModel())
            }
            .navigationDestination(isPresented: $showFindPassword) {
                FindPasswordView(viewModel: makeFindPasswordViewModel())
            }
            .loadingOverlay(isLoading: viewModel.state.isLoading || viewModel.isConnecting,
                           message: viewModel.isConnecting ? "서버에 연결 중..." : nil)
            .errorAlert($errorMessage)
            .onChange(of: viewModel.state.errorMessage) { _, newError in
                errorMessage = newError
            }
            .onChange(of: errorMessage) { _, newValue in
                if newValue == nil {
                    viewModel.clearError()
                }
            }
            .onChange(of: viewModel.connectionError) { _, newError in
                if newError != nil {
                    showConnectionError = true
                }
            }
            .alert("연결 오류", isPresented: $showConnectionError) {
                Button("다시 시도") {
                    viewModel.retryConnection()
                }
                Button("취소", role: .cancel) {
                    viewModel.clearConnectionError()
                }
            } message: {
                if let error = viewModel.connectionError {
                    Text(error)
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
        }
    }

    // MARK: - Connection Status Bar

    private var connectionStatusBar: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(viewModel.statusMessage)
                .font(.caption02)
                .foregroundColor(.textSecondary)

            Spacer()

            if !viewModel.isConnected && !viewModel.isConnecting {
                Button {
                    viewModel.retryConnection()
                } label: {
                    Text("재연결")
                        .font(.caption01)
                        .foregroundColor(.mainColor)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Color.backgroundSecondary)
    }

    private var statusColor: Color {
        switch viewModel.statusColor {
        case .connecting:
            return .orange2
        case .connected:
            return .mainColor
        case .disconnected:
            return .error
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 64))
                .foregroundColor(.mainColor)

            Text("ChatChat")
                .font(.title01)
                .foregroundColor(.textPrimary)

            Text("채팅의 새로운 시작")
                .font(.body04)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            AppTextField(
                placeholder: "아이디를 입력하세요",
                text: $viewModel.userId,
                keyboardType: .asciiCapable,
                textContentType: .username
            )
            .disabled(!viewModel.isConnected)

            AppTextField(
                placeholder: "비밀번호를 입력하세요",
                text: $viewModel.password,
                isSecure: true,
                textContentType: .password,
                onSubmit: viewModel.login
            )
            .disabled(!viewModel.isConnected)

            PrimaryButton(
                "로그인",
                isLoading: viewModel.state.isLoading,
                isEnabled: viewModel.canLogin
            ) {
                viewModel.login()
            }

            if !viewModel.isConnected && !viewModel.isConnecting {
                Text("서버에 연결된 후 로그인할 수 있습니다")
                    .font(.caption02)
                    .foregroundColor(.error)
            }

            Button {
                showFindPassword = true
            } label: {
                Text("비밀번호를 잊으셨나요?")
                    .font(.body04)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        HStack(spacing: Spacing.xs) {
            Text("계정이 없으신가요?")
                .font(.body04)
                .foregroundColor(.textSecondary)

            Button {
                showRegister = true
            } label: {
                Text("회원가입")
                    .font(.label01)
                    .foregroundColor(.mainColor)
            }
        }
    }

    // MARK: - Factory Methods

    @MainActor
    private func makeRegisterViewModel() -> RegisterViewModel {
        ViewModelFactory().makeRegisterViewModel()
    }

    @MainActor
    private func makeFindPasswordViewModel() -> FindPasswordViewModel {
        ViewModelFactory().makeFindPasswordViewModel()
    }
}
