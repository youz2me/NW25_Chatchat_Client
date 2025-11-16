//
//  RoomDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Request DTOs

/// 채팅방 생성 요청
struct CreateRoomRequestDTO: Encodable {
    let roomName: String
}

/// 채팅방 입장/퇴장 요청
struct RoomActionRequestDTO: Encodable {
    let roomId: String
}

// MARK: - Response DTOs

/// 채팅방 생성 응답
struct CreateRoomResponseDTO: Decodable {
    let roomId: String
    let roomName: String
}

/// 채팅방 입장/퇴장 응답
struct RoomActionResponseDTO: Decodable {
    let roomId: String
}

/// 채팅방 목록 응답
struct RoomListResponseDTO: Decodable {
    let rooms: [RoomItemDTO]
}

/// 채팅방 정보
struct RoomItemDTO: Decodable {
    let roomId: String
    let roomName: String
    let memberCount: Int

    func toChatRoomEntity() -> ChatRoomEntity {
        ChatRoomEntity(
            id: roomId,
            name: roomName,
            userCount: memberCount
        )
    }
}

/// 채팅방 사용자 목록 응답
struct RoomUsersResponseDTO: Decodable {
    let roomId: String
    let users: [UserItemDTO]
}
