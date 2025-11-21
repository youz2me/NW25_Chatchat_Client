//
//  LoginViewModel.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/22/25.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var userId: String = ""
    @Published var password: String = ""
    @Published var state: ViewState<SessionEntity> = .idle
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    @Published var connectionError: String? = nil

    // MARK: - Computed Properties

    var canLogin: Bool {
        !userId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !state.isLoading &&
        isConnected
    }

    var statusMessage: String {
        if isConnecting {
            return "서버에 연결 중..."
        } else if isConnected {
            return "서버에 연결됨"
        } else {
            return "서버에 연결되지 않음"
        }
    }

    var statusColor: StatusColor {
        if isConnecting {
            return .connecting
        } else if isConnected {
            return .connected
        } else {
            return .disconnected
        }
    }

    enum StatusColor {
        case connecting, connected, disconnected
    }

    // MARK: - Dependencies

    private let loginUseCase: LoginUseCaseProtocol
    private let socketClient: SocketClientProtocol?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(loginUseCase: LoginUseCaseProtocol, socketClient: SocketClientProtocol? = nil) {
        self.loginUseCase = loginUseCase
        self.socketClient = socketClient ?? DIContainer.shared.resolveOptional(SocketClientProtocol.self)

        setupSocketObserver()
    }

    // MARK: - Setup

    private func setupSocketObserver() {
        socketClient?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .connected:
                    self?.isConnected = true
                    self?.isConnecting = false
                case .disconnected(let error):
                    self?.isConnected = false
                    self?.isConnecting = false
                    if let error = error {
                        self?.connectionError = "서버 연결이 끊어졌습니다: \(error.localizedDescription)"
                    }
                case .messageReceived:
                    break
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func onAppear() {
        // 이전 연결 에러 클리어 (로그아웃 후 돌아왔을 때)
        connectionError = nil

        if !isConnected && !isConnecting {
            connectToServer()
        }
    }

    func connectToServer() {
        guard let socketClient = socketClient else {
            connectionError = "소켓 클라이언트를 초기화할 수 없습니다"
            return
        }

        isConnecting = true
        connectionError = nil

        Task {
            do {
                try await socketClient.connect(
                    host: ServerConfig.shared.host,
                    port: ServerConfig.shared.port
                )
                isConnected = true
                isConnecting = false
            } catch {
                isConnected = false
                isConnecting = false
                connectionError = "서버에 연결할 수 없습니다.\n\n\(error.localizedDescription)\n\n서버 주소: \(ServerConfig.shared.host):\(ServerConfig.shared.port)"
            }
        }
    }

    func retryConnection() {
        connectToServer()
    }

    func login() {
        guard canLogin else { return }

        state = .loading

        Task {
            do {
                let session = try await loginUseCase.execute(
                    userId: userId.trimmingCharacters(in: .whitespaces),
                    password: password
                )
                state = .success(session)

                // 로그인 성공 알림
                NotificationCenter.default.post(name: .userDidLogin, object: session)
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

    func clearConnectionError() {
        connectionError = nil
    }

    func resetForm() {
        userId = ""
        password = ""
        state = .idle
    }
}
