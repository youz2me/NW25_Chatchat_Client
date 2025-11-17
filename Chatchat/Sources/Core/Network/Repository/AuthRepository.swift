//
//  AuthRepository.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

final class AuthRepository: AuthRepositoryProtocol {

    // MARK: - Dependencies

    private let socketClient: SocketClientProtocol

    // MARK: - State

    private var _currentSession: SessionEntity?
    private let sessionSubject = CurrentValueSubject<SessionEntity?, Never>(nil)

    var currentSession: SessionEntity? { _currentSession }

    var sessionPublisher: AnyPublisher<SessionEntity?, Never> {
        sessionSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(socketClient: SocketClientProtocol) {
        self.socketClient = socketClient
    }

    // MARK: - Connection

    func connect() async throws {
        let config = ServerConfig.shared
        do {
            try await socketClient.connect(host: config.host, port: config.port)
        } catch let error as SocketError {
            throw ChatError.from(socketError: error)
        }
    }

    func disconnect() {
        socketClient.disconnect()
        _currentSession = nil
        sessionSubject.send(nil)
        SessionManager.shared.clearSession()
    }

    // MARK: - Authentication Methods

    func register(
        userId: String,
        password: String,
        name: String,
        email: String,
        securityQuestion: String,
        securityAnswer: String
    ) async throws {
        let request = Request.register(
            userId: userId,
            password: password,
            name: name,
            email: email,
            securityQuestion: securityQuestion,
            securityAnswer: securityAnswer
        )

        let response = try await sendRequest(request)

        guard response.isSuccess else {
            throw ChatError.registrationFailed(response.message)
        }
    }

    func checkIdAvailable(_ userId: String) async throws -> Bool {
        let request = Request.checkId(userId)
        let response = try await sendRequest(request)

        guard response.isSuccess,
              let available = response.data?["available"]?.value as? Bool else {
            return false
        }

        return available
    }

    func login(userId: String, password: String) async throws -> SessionEntity {
        let request = Request.login(userId: userId, password: password)
        let response = try await sendRequest(request)

        guard response.isSuccess,
              let data = response.data,
              let sessionToken = data["sessionToken"]?.value as? String,
              let userName = data["userName"]?.value as? String else {
            throw ChatError.loginFailed(response.message)
        }

        let session = SessionEntity(
            token: sessionToken,
            userId: userId,
            userName: userName
        )

        _currentSession = session
        sessionSubject.send(session)
        SessionManager.shared.setSession(session)

        return session
    }

    func logout() async throws {
        guard _currentSession != nil else {
            throw ChatError.notLoggedIn
        }

        let request = Request.logout()

        do {
            let response = try await sendRequest(request)

            guard response.isSuccess else {
                throw ChatError.unknown(response.message)
            }
        } catch { }

        _currentSession = nil
        sessionSubject.send(nil)
        SessionManager.shared.clearSession()
    }

    func findPassword(userId: String, securityAnswer: String) async throws -> String {
        let request = Request.findPassword(userId: userId, securityAnswer: securityAnswer)
        let response = try await sendRequest(request)

        guard response.isSuccess,
              let data = response.data,
              let tempPassword = data["temporaryPassword"]?.value as? String else {
            throw ChatError.unknown(response.message)
        }

        return tempPassword
    }

    // MARK: - Private Helpers

    private func sendRequest(_ request: Request) async throws -> RawResponse {
        do {
            let responseString = try await socketClient.sendAndWait(request.rawString)
            guard let response = MessageParser.parseResponse(responseString) else {
                throw ChatError.unknown("응답 파싱 실패")
            }
            return response
        } catch let error as SocketError {
            throw ChatError.from(socketError: error)
        }
    }
}
