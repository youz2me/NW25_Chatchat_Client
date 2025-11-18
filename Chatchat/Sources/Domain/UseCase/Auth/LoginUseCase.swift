//
//  LoginUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol LoginUseCaseProtocol {
    func execute(userId: String, password: String) async throws -> SessionEntity
}

// MARK: - Implementation

final class LoginUseCase: LoginUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let socketClient: SocketClientProtocol

    init(authRepository: AuthRepositoryProtocol, socketClient: SocketClientProtocol) {
        self.authRepository = authRepository
        self.socketClient = socketClient
    }

    func execute(userId: String, password: String) async throws -> SessionEntity {
        // 1. 입력 검증
        guard !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.loginFailed("아이디를 입력해주세요")
        }

        guard !password.isEmpty else {
            throw ChatError.loginFailed("비밀번호를 입력해주세요")
        }

        // 2. 서버 연결 확인
        if !socketClient.isConnected {
            try await socketClient.connect(
                host: ServerConfig.shared.host,
                port: ServerConfig.shared.port
            )
        }

        // 3. 로그인
        return try await authRepository.login(userId: userId, password: password)
    }
}
