//
//  MessageParser.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

/// JSON 메시지 파서
enum MessageParser {

    // MARK: - Response Parsing

    /// JSON 응답 문자열 파싱
    /// - Parameter raw: 서버 응답 JSON 문자열
    /// - Returns: RawResponse 객체
    static func parseResponse(_ raw: String) -> RawResponse? {
        guard let data = raw.data(using: .utf8) else { return nil }

        do {
            let response = try JSONDecoder().decode(RawResponse.self, from: data)
            return response
        } catch {
            return nil
        }
    }

    /// 타입이 지정된 응답 파싱
    /// - Parameters:
    ///   - raw: 서버 응답 JSON 문자열
    ///   - type: 데이터 타입
    /// - Returns: BaseResponse<T> 객체
    static func parseResponse<T: Decodable>(_ raw: String, as type: T.Type) -> BaseResponse<T>? {
        guard let data = raw.data(using: .utf8) else { return nil }

        do {
            let response = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
            return response
        } catch {
            return nil
        }
    }

    // MARK: - Push Event Parsing

    /// PUSH 메시지인지 확인
    static func isPushMessage(_ raw: String) -> Bool {
        guard let response = parseResponse(raw) else { return false }
        return response.isPush
    }

    /// PUSH 이벤트 파싱
    /// - Parameter raw: PUSH JSON 문자열
    /// - Returns: PushEvent
    static func parsePushEvent(_ raw: String) -> PushEvent {
        guard let response = parseResponse(raw),
              response.isPush else {
            return .unknown(raw: raw)
        }

        let eventType = response.message
        guard let data = response.data,
              let jsonData = try? JSONSerialization.data(withJSONObject: data.mapValues { $0.value }) else {
            return .unknown(raw: raw)
        }

        let decoder = JSONDecoder()

        switch eventType {
        case PushEventType.newMessage.rawValue:
            if let dto = try? decoder.decode(NewMessagePushDTO.self, from: jsonData) {
                return .newMessage(
                    roomId: dto.roomId,
                    senderId: dto.senderId,
                    senderName: dto.senderName,
                    content: dto.content,
                    timestamp: dto.timestamp
                )
            }

        case PushEventType.whisper.rawValue:
            if let dto = try? decoder.decode(WhisperPushDTO.self, from: jsonData) {
                return .whisper(
                    senderId: dto.senderId,
                    senderName: dto.senderName,
                    content: dto.content,
                    timestamp: dto.timestamp
                )
            }

        case PushEventType.userJoined.rawValue:
            if let dto = try? decoder.decode(UserJoinedPushDTO.self, from: jsonData) {
                return .userJoined(
                    roomId: dto.roomId,
                    userId: dto.userId,
                    userName: dto.userName
                )
            }

        case PushEventType.userLeft.rawValue:
            if let dto = try? decoder.decode(UserLeftPushDTO.self, from: jsonData) {
                return .userLeft(roomId: dto.roomId, userId: dto.userId)
            }

        case PushEventType.typing.rawValue:
            if let dto = try? decoder.decode(TypingPushDTO.self, from: jsonData) {
                return .typing(
                    roomId: dto.roomId,
                    userId: dto.userId,
                    isTyping: dto.isTyping
                )
            }

        case PushEventType.statusChanged.rawValue:
            if let dto = try? decoder.decode(StatusChangedPushDTO.self, from: jsonData) {
                return .statusChanged(
                    userId: dto.userId,
                    newStatus: dto.userStatus
                )
            }

        case PushEventType.roomCreated.rawValue:
            if let dto = try? decoder.decode(RoomCreatedPushDTO.self, from: jsonData) {
                return .roomCreated(roomId: dto.roomId, roomName: dto.roomName)
            }

        default:
            break
        }

        return .unknown(raw: raw)
    }

    // MARK: - List Parsing (from RawResponse data)

    /// 사용자 목록 파싱
    static func parseUserList(from response: RawResponse) -> [UserEntity] {
        guard let data = response.data,
              let usersArray = data["users"]?.value as? [[String: Any]] else {
            return []
        }

        return usersArray.compactMap { dict -> UserEntity? in
            guard let userId = dict["userId"] as? String,
                  let userName = dict["userName"] as? String else {
                return nil
            }
            let statusString = dict["status"] as? String ?? "OFFLINE"
            let status = UserStatus(rawValue: statusString) ?? .offline
            return UserEntity(id: userId, name: userName, status: status)
        }
    }

    /// 채팅방 목록 파싱
    static func parseRoomList(from response: RawResponse) -> [ChatRoomEntity] {
        guard let data = response.data,
              let roomsArray = data["rooms"]?.value as? [[String: Any]] else {
            return []
        }

        return roomsArray.compactMap { dict -> ChatRoomEntity? in
            guard let roomId = dict["roomId"] as? String,
                  let roomName = dict["roomName"] as? String else {
                return nil
            }
            let memberCount = dict["memberCount"] as? Int ?? 0
            return ChatRoomEntity(id: roomId, name: roomName, userCount: memberCount)
        }
    }

    /// 채팅방 사용자 목록 파싱
    static func parseRoomUsers(from response: RawResponse) -> [UserEntity] {
        parseUserList(from: response)
    }

    // MARK: - Validation

    static func isSuccessResponse(_ raw: String) -> Bool {
        parseResponse(raw)?.isSuccess ?? false
    }

    static func isFailResponse(_ raw: String) -> Bool {
        parseResponse(raw)?.isFail ?? false
    }
}
