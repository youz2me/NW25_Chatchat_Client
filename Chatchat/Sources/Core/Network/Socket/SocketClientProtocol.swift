//
//  SocketClientProtocol.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation
import Combine

/// 소켓 클라이언트 프로토콜 (DIP 적용)
protocol SocketClientProtocol: AnyObject {
    /// 연결 상태
    var isConnected: Bool { get }

    /// 서버 이벤트 퍼블리셔
    var eventPublisher: AnyPublisher<ServerEvent, Never> { get }

    /// 서버에 연결
    /// - Parameters:
    ///   - host: 서버 호스트
    ///   - port: 서버 포트
    func connect(host: String, port: UInt16) async throws

    /// 연결 해제
    func disconnect()

    /// 메시지 전송 (Fire and Forget)
    /// - Parameter message: 전송할 메시지
    func send(_ message: String) throws

    /// 메시지 전송 후 응답 대기
    /// - Parameters:
    ///   - message: 전송할 메시지
    ///   - timeout: 타임아웃 (초)
    /// - Returns: 서버 응답 문자열
    func sendAndWait(_ message: String, timeout: TimeInterval) async throws -> String
}

extension SocketClientProtocol {
    /// 기본 타임아웃 10초
    func sendAndWait(_ message: String) async throws -> String {
        try await sendAndWait(message, timeout: 10.0)
    }
}
