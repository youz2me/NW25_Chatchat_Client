//
//  RegisterView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import SwiftUI

struct RegisterView: View {

    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                headerSection

                formSection

                submitSection
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xl)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .loadingOverlay(isLoading: viewModel.state.isLoading || viewModel.idCheckState.isLoading)
        .errorAlert($viewModel.state, onDismiss: viewModel.clearError)
        .errorAlert($viewModel.idCheckState, onDismiss: viewModel.clearIdCheckError)
        .onChange(of: viewModel.state.isSuccess) { _, isSuccess in
            if isSuccess {
                dismiss()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("새 계정 만들기")
                .font(.title02)
                .foregroundColor(.textPrimary)

            Text("계정을 생성하고 채팅에 참여하세요! 👀")
                .font(.body04)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("아이디")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                HStack(spacing: Spacing.xs) {
                    AppTextField(
                        placeholder: "4~20자 영문, 숫자, 밑줄",
                        text: $viewModel.userId,
                        errorMessage: viewModel.userIdValidationMessage,
                        keyboardType: .asciiCapable,
                        textContentType: .username
                    )

                    Button {
                        viewModel.checkIdAvailability()
                    } label: {
                        Text(viewModel.idCheckButtonTitle)
                            .font(.label02)
                            .foregroundColor(viewModel.isIdChecked ? .mainColor : .white0)
                            .padding(.horizontal, Spacing.sm)
                            .frame(height: ComponentSize.textFieldHeight)
                            .background(viewModel.isIdChecked ? Color.green1 : Color.mainColor)
                            .cornerRadius(CornerRadius.medium)
                    }
                    .disabled(!viewModel.isUserIdValid || viewModel.idCheckState.isLoading)
                }
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("비밀번호")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                AppTextField(
                    placeholder: "4자 이상",
                    text: $viewModel.password,
                    isSecure: true,
                    errorMessage: viewModel.passwordValidationMessage,
                    textContentType: .newPassword
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("비밀번호 확인")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                AppTextField(
                    placeholder: "비밀번호를 다시 입력하세요",
                    text: $viewModel.confirmPassword,
                    isSecure: true,
                    errorMessage: viewModel.confirmPasswordValidationMessage,
                    textContentType: .newPassword
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("이름")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                AppTextField(
                    placeholder: "이름을 입력하세요",
                    text: $viewModel.name,
                    textContentType: .name
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("이메일")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                AppTextField(
                    placeholder: "example@email.com",
                    text: $viewModel.email,
                    errorMessage: viewModel.emailValidationMessage,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("보안 질문")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                Menu {
                    ForEach(0..<viewModel.securityQuestions.count, id: \.self) { index in
                        Button(viewModel.securityQuestions[index]) {
                            viewModel.selectedQuestionIndex = index
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.securityQuestions[viewModel.selectedQuestionIndex])
                            .font(.body02)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray4)
                    }
                    .padding(.horizontal, Spacing.md)
                    .frame(height: ComponentSize.textFieldHeight)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(CornerRadius.medium)
                }
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("보안 답변")
                    .font(.label01)
                    .foregroundColor(.textPrimary)

                AppTextField(
                    placeholder: "답변을 입력하세요",
                    text: $viewModel.securityAnswer
                )
            }
        }
    }

    // MARK: - Submit Section

    private var submitSection: some View {
        VStack(spacing: Spacing.md) {
            PrimaryButton(
                "회원가입",
                isLoading: viewModel.state.isLoading,
                isEnabled: viewModel.canRegister
            ) {
                viewModel.register()
            }

            if !viewModel.isIdChecked && viewModel.isUserIdValid {
                Text("아이디 중복확인을 해주세요")
                    .font(.caption02)
                    .foregroundColor(.warning)
            }
        }
    }
}
