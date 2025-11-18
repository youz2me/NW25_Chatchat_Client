//
//  RegisterUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Input Model

struct RegisterInput {
    let userId: String
    let password: String
    let confirmPassword: String
    let name: String
    let email: String
    let securityQuestion: String
    let securityAnswer: String

    init(
        userId: String,
        password: String,
        confirmPassword: String = "",
        name: String,
        email: String,
        securityQuestion: String,
        securityAnswer: String
    ) {
        self.userId = userId
        self.password = password
        self.confirmPassword = confirmPassword.isEmpty ? password : confirmPassword
        self.name = name
        self.email = email
        self.securityQuestion = securityQuestion
        self.securityAnswer = securityAnswer
    }
}

// MARK: - Protocol

protocol RegisterUseCaseProtocol {
    func execute(input: RegisterInput) async throws
    func checkIdAvailable(_ userId: String) async throws -> Bool
}

// MARK: - Implementation

final class RegisterUseCase: RegisterUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let socketClient: SocketClientProtocol

    init(authRepository: AuthRepositoryProtocol, socketClient: SocketClientProtocol) {
        self.authRepository = authRepository
        self.socketClient = socketClient
    }

    func execute(input: RegisterInput) async throws {
        // 1. 입력 검증
        try validateInput(input)

        // 2. 서버 연결 확인
        if !socketClient.isConnected {
            try await socketClient.connect(
                host: ServerConfig.shared.host,
                port: ServerConfig.shared.port
            )
        }

        // 3. 회원가입
        try await authRepository.register(
            userId: input.userId,
            password: input.password,
            name: input.name,
            email: input.email,
            securityQuestion: input.securityQuestion,
            securityAnswer: input.securityAnswer
        )
    }

    func checkIdAvailable(_ userId: String) async throws -> Bool {
        guard !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }

        // 서버 연결 확인
        if !socketClient.isConnected {
            try await socketClient.connect(
                host: ServerConfig.shared.host,
                port: ServerConfig.shared.port
            )
        }

        return try await authRepository.checkIdAvailable(userId)
    }

    // MARK: - Validation

    private func validateInput(_ input: RegisterInput) throws {
        guard !input.userId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.registrationFailed("아이디를 입력해주세요")
        }

        guard input.userId.count >= 4 else {
            throw ChatError.registrationFailed("아이디는 4자 이상이어야 합니다")
        }

        guard !input.password.isEmpty else {
            throw ChatError.registrationFailed("비밀번호를 입력해주세요")
        }

        guard input.password.count >= 4 else {
            throw ChatError.registrationFailed("비밀번호는 4자 이상이어야 합니다")
        }

        guard input.password == input.confirmPassword else {
            throw ChatError.registrationFailed("비밀번호가 일치하지 않습니다")
        }

        guard !input.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.registrationFailed("이름을 입력해주세요")
        }

        guard !input.email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.registrationFailed("이메일을 입력해주세요")
        }

        guard !input.securityQuestion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.registrationFailed("보안 질문을 입력해주세요")
        }

        guard !input.securityAnswer.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.registrationFailed("보안 답변을 입력해주세요")
        }
    }
}
