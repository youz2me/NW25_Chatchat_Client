//
//  SocketClient.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation
import Network
import Combine

/// TCP 소켓 클라이언트 구현체
/// - Thread Safety: 내부적으로 직렬 큐 사용
/// - 연결 관리, 메시지 송수신, 이벤트 발행 담당
final class SocketClient: SocketClientProtocol {

    // MARK: - Properties
    
    private let bufferLock = NSLock()
    private let pendingLock = NSLock()
    private let connectionLock = NSLock()
    private let eventSubject = PassthroughSubject<ServerEvent, Never>()
    private let queue = DispatchQueue(label: "com.chatchat.socket", qos: .userInitiated)
    
    private var receiveBuffer = ""
    private var _isConnected = false
    private var connection: NWConnection?
    private var connectContinuation: CheckedContinuation<Void, Error>?
    private var pendingContinuations: [CheckedContinuation<String, Error>] = []
    
    var isConnected: Bool {
        connectionLock.lock()
        defer { connectionLock.unlock() }
        return _isConnected
    }
    
    var eventPublisher: AnyPublisher<ServerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init() {}

    deinit {
        disconnect()
    }

    // MARK: - Connection Management

    /// 서버에 연결
    /// - Parameters:
    ///   - host: 서버 호스트
    ///   - port: 서버 포트
    /// - Throws: SocketError.connectionFailed, SocketError.alreadyConnected
    func connect(host: String, port: UInt16) async throws {
        guard !isConnected else {
            throw SocketError.alreadyConnected
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.connectContinuation = continuation

            let endpoint = NWEndpoint.hostPort(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(integerLiteral: port)
            )
            
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            let connection = NWConnection(to: endpoint, using: parameters)
            self.connection = connection
            
            connection.stateUpdateHandler = { [weak self] state in
                self?.handleStateChange(state)
            }
            
            connection.start(queue: queue)
        }
    }

    /// 연결 상태 변화 처리
    private func handleStateChange(_ state: NWConnection.State) {
        switch state {
        case .ready:
            setConnected(true)
            eventSubject.send(.connected)
            
            connectContinuation?.resume()
            connectContinuation = nil
            
            startReceiving()

        case .failed(let error):
            setConnected(false)
            let socketError = SocketError.connectionFailed(error.localizedDescription)
            eventSubject.send(.disconnected(socketError))
            
            connectContinuation?.resume(throwing: socketError)
            connectContinuation = nil
            
            cancelAllPendingRequests(with: socketError)

        case .cancelled:
            setConnected(false)
            eventSubject.send(.disconnected(nil))
            cancelAllPendingRequests(with: SocketError.connectionClosed)

        case .waiting:
            break

        default:
            break
        }
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        setConnected(false)

        bufferLock.lock()
        receiveBuffer = ""
        bufferLock.unlock()
    }

    private func setConnected(_ value: Bool) {
        connectionLock.lock()
        _isConnected = value
        connectionLock.unlock()
    }

    // MARK: - Send

    /// 메시지 전송 (응답 대기 안 함)
    /// - Parameter message: 전송할 메시지 (줄바꿈 자동 추가)
    /// - Throws: SocketError.notConnected, SocketError.sendFailed
    func send(_ message: String) throws {
        guard isConnected, let connection = connection else {
            throw SocketError.notConnected
        }

        let data = (message + Constants.ProtocolFormat.messageTerminator).data(using: Constants.Server.encoding)!

        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.eventSubject.send(.disconnected(SocketError.sendFailed(error.localizedDescription)))
            }
        })
    }

    /// 메시지 전송 후 응답 대기
    /// - Parameters:
    ///   - message: 전송할 메시지
    ///   - timeout: 타임아웃 (초)
    /// - Returns: 서버 응답 문자열
    /// - Throws: SocketError
    func sendAndWait(_ message: String, timeout: TimeInterval = 10.0) async throws -> String {
        try send(message)
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await self.waitForResponse()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw SocketError.timeout
            }

            guard let result = try await group.next() else {
                throw SocketError.timeout
            }
            group.cancelAll()
            return result
        }
    }

    /// 응답 대기 (내부용)
    private func waitForResponse() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            pendingLock.lock()
            pendingContinuations.append(continuation)
            pendingLock.unlock()
        }
    }

    // MARK: - Receive

    /// 수신 대기 시작 (재귀적으로 계속 수신)
    private func startReceiving() {
        guard let connection = connection else { return }

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if let error = error {
                // 연결 상태 초기화 후 에러 이벤트 발행
                self.setConnected(false)
                self.connection = nil
                self.eventSubject.send(.disconnected(SocketError.receiveFailed(error.localizedDescription)))
                return
            }

            if let data = data, !data.isEmpty {
                self.handleReceivedData(data)
            }

            if isComplete {
                // 연결 종료됨
                self.disconnect()
            } else {
                // 계속 수신 대기
                self.startReceiving()
            }
        }
    }

    /// 수신 데이터 처리
    /// - TCP 스트림 특성상 메시지가 분할되거나 합쳐질 수 있으므로 버퍼링 필요
    private func handleReceivedData(_ data: Data) {
        guard let string = String(data: data, encoding: Constants.Server.encoding) else { return }

        bufferLock.lock()
        receiveBuffer += string

        // 줄바꿈으로 메시지 분리
        var messages: [String] = []
        while let range = receiveBuffer.range(of: Constants.ProtocolFormat.messageTerminator) {
            let message = String(receiveBuffer[..<range.lowerBound])
            messages.append(message)
            receiveBuffer = String(receiveBuffer[range.upperBound...])
        }
        bufferLock.unlock()

        // 각 메시지 처리
        for message in messages {
            processMessage(message)
        }
    }

    /// 개별 메시지 처리
    private func processMessage(_ message: String) {
        guard !message.isEmpty else { return }

        let socketMessage = SocketMessage(raw: message)

        // JSON 파싱하여 PUSH 메시지인지 확인
        if isPushMessage(message) {
            // PUSH 메시지면 이벤트로만 발행 (응답 대기 큐에 전달하지 않음)
            eventSubject.send(.messageReceived(socketMessage))
        } else {
            // 일반 응답(OK/FAIL)이면 대기 중인 요청에 전달
            deliverResponse(message)

            // 이벤트로도 발행 (UI 업데이트용)
            eventSubject.send(.messageReceived(socketMessage))
        }
    }

    /// JSON 응답이 PUSH 메시지인지 확인
    private func isPushMessage(_ message: String) -> Bool {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let status = json["status"] as? String else {
            return false
        }
        return status == Constants.ResponseStatus.push
    }

    /// 대기 중인 요청에 응답 전달 (FIFO)
    private func deliverResponse(_ response: String) {
        pendingLock.lock()
        guard !pendingContinuations.isEmpty else {
            pendingLock.unlock()
            return
        }
        let continuation = pendingContinuations.removeFirst()
        pendingLock.unlock()

        continuation.resume(returning: response)
    }

    /// 모든 대기 요청 취소
    private func cancelAllPendingRequests(with error: Error) {
        pendingLock.lock()
        let continuations = pendingContinuations
        pendingContinuations.removeAll()
        pendingLock.unlock()

        for continuation in continuations {
            continuation.resume(throwing: error)
        }
    }
}
