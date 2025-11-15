//
//  SocketError.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

enum SocketError: LocalizedError {
    case connectionFailed(String)
    case connectionClosed
    case sendFailed(String)
    case receiveFailed(String)
    case timeout
    case invalidResponse
    case notConnected
    case alreadyConnected

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "연결 실패: \(reason)"
        case .connectionClosed:
            return "연결이 종료되었습니다"
        case .sendFailed(let reason):
            return "전송 실패: \(reason)"
        case .receiveFailed(let reason):
            return "수신 실패: \(reason)"
        case .timeout:
            return "요청 시간 초과"
        case .invalidResponse:
            return "잘못된 응답 형식"
        case .notConnected:
            return "서버에 연결되어 있지 않습니다"
        case .alreadyConnected:
            return "이미 연결되어 있습니다"
        }
    }
}
