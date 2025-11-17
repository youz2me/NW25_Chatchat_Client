//
//  AuthRepositoryProtocol.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation
import Combine

/// 인증 Repository 프로토콜
protocol AuthRepositoryProtocol: AnyObject {

    // MARK: - Properties

    /// 현재 세션
    var currentSession: SessionEntity? { get }

    /// 세션 변경 퍼블리셔
    var sessionPublisher: AnyPublisher<SessionEntity?, Never> { get }

    // MARK: - Methods

    /// 서버에 연결
    func connect() async throws

    /// 연결 해제
    func disconnect()

    /// 회원가입
    /// - Parameters:
    ///   - userId: 사용자 아이디
    ///   - password: 비밀번호
    ///   - name: 이름
    ///   - email: 이메일
    ///   - securityQuestion: 보안 질문
    ///   - securityAnswer: 보안 답변
    func register(
        userId: String,
        password: String,
        name: String,
        email: String,
        securityQuestion: String,
        securityAnswer: String
    ) async throws

    /// 아이디 중복 확인
    /// - Parameter userId: 확인할 아이디
    /// - Returns: 사용 가능 여부
    func checkIdAvailable(_ userId: String) async throws -> Bool

    /// 로그인
    /// - Parameters:
    ///   - userId: 사용자 아이디
    ///   - password: 비밀번호
    /// - Returns: 세션 정보
    @discardableResult
    func login(userId: String, password: String) async throws -> SessionEntity

    /// 로그아웃
    func logout() async throws

    /// 비밀번호 찾기
    /// - Parameters:
    ///   - userId: 사용자 아이디
    ///   - securityAnswer: 보안 답변
    /// - Returns: 임시 비밀번호
    func findPassword(userId: String, securityAnswer: String) async throws -> String
}
