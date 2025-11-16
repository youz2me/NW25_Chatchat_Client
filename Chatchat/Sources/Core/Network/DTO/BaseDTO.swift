//
//  BaseDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Base Request

/// 서버 요청 기본 구조
struct BaseRequest<T: Encodable>: Encodable {
    let command: String
    let data: T

    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

/// 빈 데이터를 위한 구조체
struct EmptyData: Codable {}

// MARK: - Base Response

/// 서버 응답 기본 구조
struct BaseResponse<T: Decodable>: Decodable {
    let status: String
    let message: String
    let data: T?

    var isSuccess: Bool { status == "OK" }
    var isPush: Bool { status == "PUSH" }
    var isFail: Bool { status == "FAIL" }

    var errorCode: String? {
        guard isFail else { return nil }
        if let errorData = data as? ErrorData {
            return errorData.errorCode
        }
        return nil
    }
}

/// 에러 응답 데이터
struct ErrorData: Decodable {
    let errorCode: String
}

// MARK: - Raw Response (for initial parsing)

/// JSON 파싱을 위한 Raw 응답
struct RawResponse: Decodable {
    let status: String
    let message: String
    let data: [String: AnyCodable]?

    var isSuccess: Bool { status == "OK" }
    var isPush: Bool { status == "PUSH" }
    var isFail: Bool { status == "FAIL" }

    var errorCode: String? {
        guard isFail else { return nil }
        return data?["errorCode"]?.value as? String
    }
}

// MARK: - AnyCodable (for dynamic JSON parsing)

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}

// MARK: - Protocol Error Codes

enum ProtocolErrorCode: String {
    case invalidFormat = "INVALID_FORMAT"
    case invalidSession = "INVALID_SESSION"
    case loginFailed = "LOGIN_FAILED"
    case registerFailed = "REGISTER_FAILED"
    case findPwFailed = "FIND_PW_FAILED"
    case msgFailed = "MSG_FAILED"
    case whisperFailed = "WHISPER_FAILED"
    case roomCreateFailed = "ROOM_CREATE_FAILED"
    case roomJoinFailed = "ROOM_JOIN_FAILED"
    case roomLeaveFailed = "ROOM_LEAVE_FAILED"
    case unknownCommand = "UNKNOWN_COMMAND"

    var localizedMessage: String {
        switch self {
        case .invalidFormat: return "잘못된 요청 형식입니다"
        case .invalidSession: return "로그인이 필요합니다"
        case .loginFailed: return "아이디 또는 비밀번호가 일치하지 않습니다"
        case .registerFailed: return "회원가입에 실패했습니다"
        case .findPwFailed: return "비밀번호 찾기에 실패했습니다"
        case .msgFailed: return "메시지 전송에 실패했습니다"
        case .whisperFailed: return "귓속말 전송에 실패했습니다"
        case .roomCreateFailed: return "채팅방 생성에 실패했습니다"
        case .roomJoinFailed: return "채팅방 입장에 실패했습니다"
        case .roomLeaveFailed: return "채팅방 퇴장에 실패했습니다"
        case .unknownCommand: return "알 수 없는 명령어입니다"
        }
    }
}
