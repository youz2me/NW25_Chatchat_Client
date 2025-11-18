//
//  LogoutUseCase.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Protocol

protocol LogoutUseCaseProtocol {
    func execute() async throws
}

// MARK: - Implementation

final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute() async throws {
        // 1. 먼저 연결 해제 (서버가 먼저 끊기 전에 클라이언트가 끊음)
        authRepository.disconnect()

        // 2. 로컬 세션 정리는 disconnect()에서 처리됨
    }
}
