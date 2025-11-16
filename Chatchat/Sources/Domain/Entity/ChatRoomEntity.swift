//
//  ChatRoomEntity.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

struct ChatRoomEntity: Identifiable, Equatable, Sendable, Hashable {
    let id: String
    let name: String
    let creatorId: String
    var userCount: Int
    let createdAt: Date

    init(
        id: String,
        name: String,
        creatorId: String = "",
        userCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.creatorId = creatorId
        self.userCount = userCount
        self.createdAt = createdAt
    }

    var isLobby: Bool {
        id == Self.lobbyId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChatRoomEntity, rhs: ChatRoomEntity) -> Bool {
        lhs.id == rhs.id
    }
}

extension ChatRoomEntity {
    static let lobbyId = "LOBBY"

    /// 로비 채팅방
    static let lobby = ChatRoomEntity(
        id: lobbyId,
        name: "로비",
        creatorId: "SYSTEM",
        userCount: 0,
        createdAt: Date()
    )

    /// 표시용 문자열
    var displayName: String {
        isLobby ? "🏠 \(name)" : "💬 \(name)"
    }

    var userCountDisplay: String {
        "👥 \(userCount)"
    }
}
