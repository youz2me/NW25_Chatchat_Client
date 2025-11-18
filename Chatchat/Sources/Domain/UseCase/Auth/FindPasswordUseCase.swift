//
//  FindPasswordUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol FindPasswordUseCaseProtocol {
    func execute(userId: String, securityAnswer: String) async throws -> String
}

// MARK: - Implementation

final class FindPasswordUseCase: FindPasswordUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol
    private let socketClient: SocketClientProtocol

    init(authRepository: AuthRepositoryProtocol, socketClient: SocketClientProtocol) {
        self.authRepository = authRepository
        self.socketClient = socketClient
    }

    func execute(userId: String, securityAnswer: String) async throws -> String {
        // 1. 입력 검증
        guard !userId.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.unknown("아이디를 입력해주세요")
        }

        guard !securityAnswer.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ChatError.unknown("보안 답변을 입력해주세요")
        }

        // 2. 서버 연결 확인
        if !socketClient.isConnected {
            try await socketClient.connect(
                host: ServerConfig.shared.host,
                port: ServerConfig.shared.port
            )
        }

        // 3. 비밀번호 찾기
        return try await authRepository.findPassword(
            userId: userId,
            securityAnswer: securityAnswer
        )
    }
}
