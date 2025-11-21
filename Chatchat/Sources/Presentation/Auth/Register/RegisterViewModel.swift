//
//  RegisterViewModel.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {

    // MARK: - Input Properties

    @Published var userId: String = "" {
        didSet { resetIdCheckIfNeeded(oldValue: oldValue) }
    }
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var selectedQuestionIndex: Int = 0
    @Published var securityAnswer: String = ""

    // MARK: - State Properties

    @Published var state: ViewState<Void> = .idle
    @Published var idCheckState: ViewState<Bool> = .idle
    @Published private(set) var isIdChecked: Bool = false

    // MARK: - Constants

    let securityQuestions = [
        "처음 키운 반려동물 이름은?",
        "태어난 도시는?",
        "어머니 성함은?",
        "졸업한 초등학교는?",
        "가장 좋아하는 영화는?"
    ]

    // MARK: - Validation

    var isUserIdValid: Bool {
        let trimmed = userId.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 4, trimmed.count <= 20 else { return false }
        let regex = "^[a-zA-Z0-9_]+$"
        return trimmed.range(of: regex, options: .regularExpression) != nil
    }

    var userIdValidationMessage: String? {
        guard !userId.isEmpty else { return nil }
        if userId.count < 4 {
            return "아이디는 4자 이상이어야 합니다"
        }
        if userId.count > 20 {
            return "아이디는 20자 이하여야 합니다"
        }
        if !isUserIdValid {
            return "영문, 숫자, 밑줄(_)만 사용 가능합니다"
        }
        return nil
    }

    var isPasswordValid: Bool {
        password.count >= 4
    }

    var passwordValidationMessage: String? {
        guard !password.isEmpty else { return nil }
        if password.count < 4 {
            return "비밀번호는 4자 이상이어야 합니다"
        }
        return nil
    }

    var isConfirmPasswordValid: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    var confirmPasswordValidationMessage: String? {
        guard !confirmPassword.isEmpty else { return nil }
        if password != confirmPassword {
            return "비밀번호가 일치하지 않습니다"
        }
        return nil
    }

    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let regex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return trimmed.range(of: regex, options: .regularExpression) != nil
    }

    var emailValidationMessage: String? {
        guard !email.isEmpty else { return nil }
        if !isEmailValid {
            return "올바른 이메일 형식이 아닙니다"
        }
        return nil
    }

    var isSecurityAnswerValid: Bool {
        !securityAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canRegister: Bool {
        isUserIdValid &&
        isPasswordValid &&
        isConfirmPasswordValid &&
        isNameValid &&
        isEmailValid &&
        isSecurityAnswerValid &&
        isIdChecked &&
        !state.isLoading
    }

    var idCheckButtonTitle: String {
        if idCheckState.isLoading {
            return "확인 중..."
        }
        if isIdChecked {
            return "사용 가능"
        }
        return "중복 확인"
    }

    // MARK: - Dependencies

    private let registerUseCase: RegisterUseCaseProtocol

    // MARK: - Initialization

    init(registerUseCase: RegisterUseCaseProtocol) {
        self.registerUseCase = registerUseCase
    }

    // MARK: - Actions

    func checkIdAvailability() {
        guard isUserIdValid, !idCheckState.isLoading else { return }

        idCheckState = .loading

        Task {
            do {
                let isAvailable = try await registerUseCase.checkIdAvailable(
                    userId.trimmingCharacters(in: .whitespaces)
                )
                idCheckState = .success(isAvailable)
                isIdChecked = isAvailable

                if !isAvailable {
                    idCheckState = .error("이미 사용 중인 아이디입니다")
                }
            } catch {
                idCheckState = .error(error.localizedDescription)
                isIdChecked = false
            }
        }
    }

    func register() {
        guard canRegister else { return }

        state = .loading

        Task {
            do {
                let input = RegisterInput(
                    userId: userId.trimmingCharacters(in: .whitespaces),
                    password: password,
                    confirmPassword: confirmPassword,
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces),
                    securityQuestion: securityQuestions[selectedQuestionIndex],
                    securityAnswer: securityAnswer.trimmingCharacters(in: .whitespaces)
                )
                try await registerUseCase.execute(input: input)
                state = .success(())
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func clearError() {
        if state.isError {
            state = .idle
        }
    }

    func clearIdCheckError() {
        if idCheckState.isError {
            idCheckState = .idle
        }
    }

    func resetForm() {
        userId = ""
        password = ""
        confirmPassword = ""
        name = ""
        email = ""
        selectedQuestionIndex = 0
        securityAnswer = ""
        state = .idle
        idCheckState = .idle
        isIdChecked = false
    }

    // MARK: - Private

    private func resetIdCheckIfNeeded(oldValue: String) {
        if oldValue != userId {
            isIdChecked = false
            idCheckState = .idle
        }
    }
}
