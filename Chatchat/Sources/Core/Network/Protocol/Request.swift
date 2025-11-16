//
//  Request.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

/// 서버 요청 명령어
enum ChatCommand: String, Sendable {
    // 인증
    case register = "REGISTER"
    case checkId = "CHECK_ID"
    case login = "LOGIN"
    case logout = "LOGOUT"
    case findPassword = "FIND_PW"

    // 사용자
    case status = "STATUS"
    case userList = "USER_LIST"

    // 채팅
    case message = "MSG"
    case whisper = "WHISPER"
    case typing = "TYPING"

    // 채팅방
    case roomCreate = "ROOM_CREATE"
    case roomList = "ROOM_LIST"
    case roomJoin = "ROOM_JOIN"
    case roomLeave = "ROOM_LEAVE"
    case roomUsers = "ROOM_USERS"
}

/// JSON 서버 요청 빌더
struct Request: Sendable {
    let command: ChatCommand
    private let jsonString: String

    var rawString: String { jsonString }

    // MARK: - Private Initializer

    private init<T: Encodable>(command: ChatCommand, data: T) {
        self.command = command

        let encoder = JSONEncoder()
        let wrapper = RequestWrapper(command: command.rawValue, data: data)

        if let jsonData = try? encoder.encode(wrapper),
           let string = String(data: jsonData, encoding: .utf8) {
            self.jsonString = string
        } else {
            self.jsonString = "{\"command\":\"\(command.rawValue)\",\"data\":{}}"
        }
    }

    // MARK: - Factory Methods (인증)

    static func register(
        userId: String,
        password: String,
        name: String,
        email: String,
        securityQuestion: String,
        securityAnswer: String
    ) -> Request {
        let data = RegisterRequestDTO(
            userId: userId,
            password: password,
            name: name,
            email: email,
            securityQuestion: securityQuestion,
            securityAnswer: securityAnswer
        )
        return Request(command: .register, data: data)
    }

    static func checkId(_ userId: String) -> Request {
        let data = CheckIdRequestDTO(userId: userId)
        return Request(command: .checkId, data: data)
    }

    static func login(userId: String, password: String) -> Request {
        let data = LoginRequestDTO(userId: userId, password: password)
        return Request(command: .login, data: data)
    }

    static func logout() -> Request {
        Request(command: .logout, data: EmptyData())
    }

    static func findPassword(userId: String, securityAnswer: String) -> Request {
        let data = FindPasswordRequestDTO(userId: userId, securityAnswer: securityAnswer)
        return Request(command: .findPassword, data: data)
    }

    // MARK: - Factory Methods (사용자)

    static func changeStatus(_ status: UserStatus) -> Request {
        let data = ChangeStatusRequestDTO(status: status.rawValue)
        return Request(command: .status, data: data)
    }

    static func getUserList() -> Request {
        Request(command: .userList, data: EmptyData())
    }

    // MARK: - Factory Methods (채팅)

    static func sendMessage(roomId: String, content: String) -> Request {
        let data = SendMessageRequestDTO(roomId: roomId, content: content)
        return Request(command: .message, data: data)
    }

    static func sendWhisper(targetUserId: String, content: String) -> Request {
        let data = SendWhisperRequestDTO(targetUserId: targetUserId, content: content)
        return Request(command: .whisper, data: data)
    }

    static func typing(roomId: String, isTyping: Bool) -> Request {
        let data = TypingRequestDTO(roomId: roomId, isTyping: isTyping)
        return Request(command: .typing, data: data)
    }

    // MARK: - Factory Methods (채팅방)

    static func createRoom(name: String) -> Request {
        let data = CreateRoomRequestDTO(roomName: name)
        return Request(command: .roomCreate, data: data)
    }

    static func getRoomList() -> Request {
        Request(command: .roomList, data: EmptyData())
    }

    static func joinRoom(_ roomId: String) -> Request {
        let data = RoomActionRequestDTO(roomId: roomId)
        return Request(command: .roomJoin, data: data)
    }

    static func leaveRoom(_ roomId: String) -> Request {
        let data = RoomActionRequestDTO(roomId: roomId)
        return Request(command: .roomLeave, data: data)
    }

    static func getRoomUsers(_ roomId: String) -> Request {
        let data = RoomActionRequestDTO(roomId: roomId)
        return Request(command: .roomUsers, data: data)
    }
}

// MARK: - Request Wrapper for JSON Encoding

private struct RequestWrapper<T: Encodable>: Encodable {
    let command: String
    let data: T
}
