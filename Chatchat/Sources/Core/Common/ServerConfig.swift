//
//  ServerConfig.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import Foundation

/// 서버 설정 관리 - UserDefaults에 저장

final class ServerConfig {
    static let shared = ServerConfig()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let host = "server_host"
        static let port = "server_port"
    }

    var host: String {
        get { defaults.string(forKey: Keys.host) ?? Constants.Server.host }
        set { defaults.set(newValue, forKey: Keys.host) }
    }

    var port: UInt16 {
        get {
            let value = defaults.integer(forKey: Keys.port)
            return value != 0 ? UInt16(value) : Constants.Server.port
        }
        set { defaults.set(Int(newValue), forKey: Keys.port) }
    }

    private init() {}
    
    func reset() {
        defaults.removeObject(forKey: Keys.host)
        defaults.removeObject(forKey: Keys.port)
    }
}
