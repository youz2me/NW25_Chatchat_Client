//
//  RoomRepositoryProtocol.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

/// 채팅방 Repository 프로토콜
protocol RoomRepositoryProtocol: AnyObject {

    // MARK: - Properties

    /// 현재 참여 중인 채팅방 ID
    var currentRoomId: String { get }

    // MARK: - Publishers

    /// 현재 채팅방 변경 퍼블리셔
    var currentRoomPublisher: AnyPublisher<String, Never> { get }

    /// 사용자 입장 퍼블리셔
    var userJoinedPublisher: AnyPublisher<(roomId: String, user: UserEntity), Never> { get }

    /// 사용자 퇴장 퍼블리셔
    var userLeftPublisher: AnyPublisher<(roomId: String, userId: String), Never> { get }

    /// 새 채팅방 생성 퍼블리셔
    var roomCreatedPublisher: AnyPublisher<ChatRoomEntity, Never> { get }

    // MARK: - Methods

    /// 채팅방 생성
    /// - Parameter name: 채팅방 이름
    /// - Returns: 생성된 채팅방
    @discardableResult
    func createRoom(name: String) async throws -> ChatRoomEntity

    /// 채팅방 목록 조회
    /// - Returns: 채팅방 목록
    func getRoomList() async throws -> [ChatRoomEntity]

    /// 채팅방 입장
    /// - Parameter roomId: 채팅방 ID
    func joinRoom(_ roomId: String) async throws

    /// 채팅방 퇴장
    /// - Parameter roomId: 채팅방 ID
    func leaveRoom(_ roomId: String) async throws

    /// 채팅방 사용자 목록 조회
    /// - Parameter roomId: 채팅방 ID
    /// - Returns: 사용자 목록
    func getRoomUsers(_ roomId: String) async throws -> [UserEntity]
}
