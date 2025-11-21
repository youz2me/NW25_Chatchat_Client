//
//  FindPasswordViewModel.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import Foundation
import Combine

@MainActor
final class FindPasswordViewModel: ObservableObject {

    // MARK: - Input Properties

    @Published var userId: String = ""
    @Published var securityAnswer: String = ""

    // MARK: - State Properties

    @Published var state: ViewState<String> = .idle

    // MARK: - Computed Properties

    var canSubmit: Bool {
        !userId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !securityAnswer.trimmingCharacters(in: .whitespaces).isEmpty &&
        !state.isLoading
    }

    var temporaryPassword: String? {
        state.value
    }

    var isSuccess: Bool {
        state.isSuccess
    }

    // MARK: - Dependencies

    private let findPasswordUseCase: FindPasswordUseCaseProtocol

    // MARK: - Initialization

    init(findPasswordUseCase: FindPasswordUseCaseProtocol) {
        self.findPasswordUseCase = findPasswordUseCase
    }

    // MARK: - Actions

    func findPassword() {
        guard canSubmit else { return }

        state = .loading

        Task {
            do {
                let tempPassword = try await findPasswordUseCase.execute(
                    userId: userId.trimmingCharacters(in: .whitespaces),
                    securityAnswer: securityAnswer.trimmingCharacters(in: .whitespaces)
                )
                state = .success(tempPassword)
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

    func resetForm() {
        userId = ""
        securityAnswer = ""
        state = .idle
    }
}
