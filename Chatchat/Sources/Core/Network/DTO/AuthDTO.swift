//
//  AuthDTO.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/17/25.
//

import Foundation

// MARK: - Request DTOs

/// 회원가입 요청
struct RegisterRequestDTO: Encodable {
    let userId: String
    let password: String
    let name: String
    let email: String
    let securityQuestion: String
    let securityAnswer: String
}

/// 아이디 중복 확인 요청
struct CheckIdRequestDTO: Encodable {
    let userId: String
}

/// 로그인 요청
struct LoginRequestDTO: Encodable {
    let userId: String
    let password: String
}

/// 비밀번호 찾기 요청
struct FindPasswordRequestDTO: Encodable {
    let userId: String
    let securityAnswer: String
}

// MARK: - Response DTOs

/// 회원가입 응답
struct RegisterResponseDTO: Decodable {
    let userId: String
}

/// 아이디 중복 확인 응답
struct CheckIdResponseDTO: Decodable {
    let userId: String
    let available: Bool
}

/// 로그인 응답
struct LoginResponseDTO: Decodable {
    let sessionToken: String
    let userName: String
}

/// 비밀번호 찾기 응답
struct FindPasswordResponseDTO: Decodable {
    let temporaryPassword: String
}
