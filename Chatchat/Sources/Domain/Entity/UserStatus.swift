//
//  UserStatus.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/16/25.
//

import Foundation

enum UserStatus: String, CaseIterable, Sendable, Codable {
    case online = "ONLINE"
    case away = "AWAY"
    case busy = "BUSY"
    case offline = "OFFLINE"

    var displayName: String {
        switch self {
        case .online: return "온라인"
        case .away: return "자리비움"
        case .busy: return "바쁨"
        case .offline: return "오프라인"
        }
    }

    var emoji: String {
        switch self {
        case .online: return "🟢"
        case .away: return "🟡"
        case .busy: return "🔴"
        case .offline: return "⚪"
        }
    }

    var isAvailable: Bool {
        self == .online || self == .away
    }
}
