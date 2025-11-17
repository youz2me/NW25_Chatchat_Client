//
//  ChatRepositoryProtocol.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

/// 채팅 Repository 프로토콜
protocol ChatRepositoryProtocol: AnyObject {

    // MARK: - Publishers

    /// 메시지 수신 퍼블리셔
    var messagePublisher: AnyPublisher<MessageEntity, Never> { get }

    /// 귓속말 수신 퍼블리셔
    var whisperPublisher: AnyPublisher<MessageEntity, Never> { get }

    /// 타이핑 상태 퍼블리셔
    var typingPublisher: AnyPublisher<(roomId: String, userId: String, isTyping: Bool), Never> { get }

    /// 사용자 상태 변경 퍼블리셔
    var userStatusPublisher: AnyPublisher<(userId: String, status: UserStatus), Never> { get }

    // MARK: - Methods

    /// 메시지 전송
    /// - Parameters:
    ///   - roomId: 채팅방 ID
    ///   - content: 메시지 내용
    func sendMessage(roomId: String, content: String) async throws

    /// 귓속말 전송
    /// - Parameters:
    ///   - targetUserId: 대상 사용자 ID
    ///   - content: 메시지 내용
    func sendWhisper(targetUserId: String, content: String) async throws

    /// 타이핑 상태 전송 (Fire and Forget)
    /// - Parameters:
    ///   - roomId: 채팅방 ID
    ///   - isTyping: 타이핑 중 여부
    func sendTyping(roomId: String, isTyping: Bool)

    /// 상태 변경
    /// - Parameter status: 새 상태
    func changeStatus(_ status: UserStatus) async throws

    /// 사용자 목록 조회
    /// - Returns: 사용자 목록
    func getUserList() async throws -> [UserEntity]
}
