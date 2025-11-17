//
//  ChatError.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

/// 채팅 앱 에러 타입
enum ChatError: LocalizedError, Equatable {
    // 인증 관련
    case notLoggedIn
    case registrationFailed(String)
    case loginFailed(String)
    case idAlreadyExists
    case invalidCredentials
    case securityAnswerMismatch

    // 사용자 관련
    case userNotFound

    // 채팅방 관련
    case roomNotFound
    case alreadyInRoom
    case notInRoom
    case cannotLeaveLobby

    // 메시지 관련
    case messageSendFailed(String)
    case whisperFailed(String)

    // 네트워크 관련
    case notConnected
    case connectionFailed(String)
    case networkError(String)
    case timeout

    // 기타
    case invalidResponse
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "로그인이 필요합니다"
        case .registrationFailed(let reason):
            return "회원가입 실패: \(reason)"
        case .loginFailed(let reason):
            return "로그인 실패: \(reason)"
        case .idAlreadyExists:
            return "이미 존재하는 아이디입니다"
        case .invalidCredentials:
            return "아이디 또는 비밀번호가 일치하지 않습니다"
        case .securityAnswerMismatch:
            return "보안 답변이 일치하지 않습니다"
        case .userNotFound:
            return "사용자를 찾을 수 없습니다"
        case .roomNotFound:
            return "채팅방을 찾을 수 없습니다"
        case .alreadyInRoom:
            return "이미 채팅방에 참여 중입니다"
        case .notInRoom:
            return "해당 채팅방에 참여하고 있지 않습니다"
        case .cannotLeaveLobby:
            return "로비는 나갈 수 없습니다"
        case .messageSendFailed(let reason):
            return "메시지 전송 실패: \(reason)"
        case .whisperFailed(let reason):
            return "귓속말 전송 실패: \(reason)"
        case .notConnected:
            return "서버에 연결되어 있지 않습니다"
        case .connectionFailed(let reason):
            return "연결 실패: \(reason)"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .timeout:
            return "요청 시간이 초과되었습니다"
        case .invalidResponse:
            return "잘못된 서버 응답입니다"
        case .unknown(let message):
            return message
        }
    }

    /// 프로토콜 에러 코드에서 변환
    static func from(protocolError: ProtocolErrorCode) -> ChatError {
        switch protocolError {
        case .invalidFormat:
            return .invalidResponse
        case .invalidSession:
            return .notLoggedIn
        case .loginFailed:
            return .invalidCredentials
        case .registerFailed:
            return .idAlreadyExists
        case .findPwFailed:
            return .securityAnswerMismatch
        case .msgFailed:
            return .messageSendFailed("전송 실패")
        case .whisperFailed:
            return .whisperFailed("전송 실패")
        case .roomCreateFailed:
            return .unknown("채팅방 생성 실패")
        case .roomJoinFailed:
            return .roomNotFound
        case .roomLeaveFailed:
            return .notInRoom
        case .unknownCommand:
            return .invalidResponse
        }
    }

    /// 소켓 에러에서 변환
    static func from(socketError: SocketError) -> ChatError {
        switch socketError {
        case .connectionFailed(let reason):
            return .connectionFailed(reason)
        case .connectionClosed:
            return .notConnected
        case .sendFailed(let reason):
            return .networkError(reason)
        case .receiveFailed(let reason):
            return .networkError(reason)
        case .timeout:
            return .timeout
        case .invalidResponse:
            return .invalidResponse
        case .notConnected:
            return .notConnected
        case .alreadyConnected:
            return .networkError("이미 연결되어 있습니다")
        }
    }
}
