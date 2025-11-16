//
//  UserEntity.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

struct UserEntity: Identifiable, Equatable, Sendable, Hashable {
    let id: String
    let name: String
    let email: String
    var status: UserStatus
    var lastLoginAt: Date?

    init(
        id: String,
        name: String,
        email: String = "",
        status: UserStatus = .offline,
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.status = status
        self.lastLoginAt = lastLoginAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UserEntity, rhs: UserEntity) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status
    }
}

extension UserEntity {
    /// 상태 표시 문자열
    var statusDisplay: String {
        "\(status.emoji) \(name)"
    }
}
