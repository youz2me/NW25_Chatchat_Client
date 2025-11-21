//
//  FindPasswordView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import SwiftUI

struct FindPasswordView: View {

    @StateObject private var viewModel: FindPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isCopied: Bool = false

    init(viewModel: FindPasswordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            if viewModel.isSuccess {
                successContent
            } else {
                formContent
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .background(Color.backgroundPrimary)
        .navigationTitle("비밀번호 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(isLoading: viewModel.state.isLoading)
        .errorAlert($viewModel.state, onDismiss: viewModel.clearError)
    }

    // MARK: - Form Content

    private var formContent: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            VStack(spacing: Spacing.xs) {
                Image(systemName: "lock.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.mainColor)

                Text("비밀번호를 찾으시나요?")
                    .font(.title02)
                    .foregroundColor(.textPrimary)

                Text("가입 시 설정한 보안 질문으로\n임시 비밀번호를 발급받을 수 있습니다")
                    .font(.body04)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Form
            VStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("아이디")
                        .font(.label01)
                        .foregroundColor(.textPrimary)

                    AppTextField(
                        placeholder: "가입한 아이디를 입력하세요",
                        text: $viewModel.userId,
                        keyboardType: .asciiCapable,
                        textContentType: .username
                    )
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("보안 질문 답변")
                        .font(.label01)
                        .foregroundColor(.textPrimary)

                    AppTextField(
                        placeholder: "보안 질문의 답변을 입력하세요",
                        text: $viewModel.securityAnswer,
                        onSubmit: viewModel.findPassword
                    )
                }

                PrimaryButton(
                    "비밀번호 찾기",
                    isLoading: viewModel.state.isLoading,
                    isEnabled: viewModel.canSubmit
                ) {
                    viewModel.findPassword()
                }
            }
        }
    }

    // MARK: - Success Content

    private var successContent: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            VStack(spacing: Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.mainColor)

                Text("임시 비밀번호 발급 완료")
                    .font(.title02)
                    .foregroundColor(.textPrimary)
            }

            // Temporary Password Box
            if let tempPassword = viewModel.temporaryPassword {
                VStack(spacing: Spacing.sm) {
                    Text("임시 비밀번호")
                        .font(.label01)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: Spacing.sm) {
                        Text(tempPassword)
                            .font(.title01)
                            .foregroundColor(.mainColor)

                        Button {
                            UIPasteboard.general.string = tempPassword
                            isCopied = true

                            // 2초 후 복사 완료 상태 리셋
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                            }
                        } label: {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 16))
                                .foregroundColor(isCopied ? .mainColor : .gray4)
                        }
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color.green1)
                    .cornerRadius(CornerRadius.medium)

                    Text(isCopied ? "클립보드에 복사되었습니다!" : "로그인 후 비밀번호를 변경해주세요")
                        .font(.caption02)
                        .foregroundColor(isCopied ? .mainColor : .textSecondary)
                }
            }

            // Actions
            VStack(spacing: Spacing.sm) {
                PrimaryButton("로그인하러 가기") {
                    dismiss()
                }

                Button {
                    viewModel.resetForm()
                } label: {
                    Text("다른 계정 찾기")
                        .font(.label01)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
}
