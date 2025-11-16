//
//  UserDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Request DTOs

/// 상태 변경 요청
struct ChangeStatusRequestDTO: Encodable {
    let status: String
}

// MARK: - Response DTOs

/// 상태 변경 응답
struct ChangeStatusResponseDTO: Decodable {
    let status: String
}

/// 사용자 목록 응답
struct UserListResponseDTO: Decodable {
    let users: [UserItemDTO]
}

/// 사용자 정보
struct UserItemDTO: Decodable {
    let userId: String
    let userName: String
    let status: String

    func toUser() -> UserEntity {
        UserEntity(
            id: userId,
            name: userName,
            status: UserStatus(rawValue: status) ?? .offline
        )
    }
}
