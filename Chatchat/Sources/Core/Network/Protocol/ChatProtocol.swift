//
//  ChatProtocol.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

// MARK: - Response Status

enum ResponseStatus: String, Sendable {
    case ok = "OK"
    case fail = "FAIL"
    case push = "PUSH"
}
