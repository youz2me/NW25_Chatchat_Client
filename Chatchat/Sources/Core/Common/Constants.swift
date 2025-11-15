//
//  Constants.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

enum Constants {

    // MARK: - Server
    
    enum Server {
        static let host = "localhost"
        static let port: UInt16 = 9000
        static let encoding: String.Encoding = .utf8
    }

    // MARK: - Protocol Format
    
    enum ProtocolFormat {
        static let fieldSeparator = "|"
        static let messageTerminator = "\n"
        static let listSeparator = ","
        static let itemSeparator = ":"
    }

    // MARK: - Commands
    
    enum Command {
        static let register = "REGISTER"
        static let checkId = "CHECK_ID"
        static let login = "LOGIN"
        static let logout = "LOGOUT"
        static let findPassword = "FIND_PW"

        static let status = "STATUS"
        static let userList = "USER_LIST"
        
        static let message = "MSG"
        static let whisper = "WHISPER"
        static let typing = "TYPING"
        
        static let roomCreate = "ROOM_CREATE"
        static let roomList = "ROOM_LIST"
        static let roomJoin = "ROOM_JOIN"
        static let roomLeave = "ROOM_LEAVE"
        static let roomUsers = "ROOM_USERS"
    }

    // MARK: - Response Status
    
    enum ResponseStatus {
        static let ok = "OK"
        static let fail = "FAIL"
        static let push = "PUSH"
    }

    // MARK: - Response Types
    
    enum ResponseType {
        static let registered = "REGISTERED"
        static let available = "AVAILABLE"
        static let taken = "TAKEN"
        static let login = "LOGIN"
        static let loggedOut = "LOGGED_OUT"
        static let findPassword = "FIND_PW"
        static let statusChanged = "STATUS_CHANGED"
        static let userList = "USER_LIST"
        static let msgSent = "MSG_SENT"
        static let whisperSent = "WHISPER_SENT"
        static let roomCreate = "ROOM_CREATE"
        static let roomList = "ROOM_LIST"
        static let joined = "JOINED"
        static let left = "LEFT"
        static let roomUsers = "ROOM_USERS"
    }

    // MARK: - Push Types
    
    enum PushType {
        static let userJoined = "USER_JOINED"
        static let userLeft = "USER_LEFT"
        static let newMessage = "NEW_MSG"
        static let whisper = "WHISPER"
        static let typing = "TYPING"
        static let statusChanged = "STATUS_CHANGED"
        static let roomCreated = "ROOM_CREATED"
    }

    // MARK: - Error Codes
    
    enum ErrorCode {
        static let invalidCredentials = "INVALID_CREDENTIALS"
        static let userNotFound = "USER_NOT_FOUND"
        static let userAlreadyExists = "USER_ALREADY_EXISTS"
        static let roomNotFound = "ROOM_NOT_FOUND"
        static let alreadyInRoom = "ALREADY_IN_ROOM"
        static let notInRoom = "NOT_IN_ROOM"
        static let invalidSession = "INVALID_SESSION"
        static let invalidFormat = "INVALID_FORMAT"
        static let securityAnswerMismatch = "SECURITY_ANSWER_MISMATCH"
    }

    // MARK: - Default Values
    
    enum Defaults {
        static let lobbyRoomId = "LOBBY"
    }
}
