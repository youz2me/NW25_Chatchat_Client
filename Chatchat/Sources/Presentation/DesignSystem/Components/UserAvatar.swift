//
//  UserAvatar.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

struct UserAvatar: View {
    
    // MARK: - Properties

    let name: String
    var status: UserStatus? = nil
    var size: Size = .medium

    enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return ComponentSize.avatarSmall
            case .medium: return ComponentSize.avatarMedium
            case .large: return ComponentSize.avatarLarge
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .caption01
            case .medium: return .body03
            case .large: return .body01
            }
        }

        var statusSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }
        }
    }
    
    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(avatarColor)
                .frame(width: size.dimension, height: size.dimension)
                .overlay(
                    Text(initial)
                        .font(size.fontSize)
                        .fontWeight(.semibold)
                        .foregroundColor(.white0)
                )
            
            if let status = status {
                Circle()
                    .fill(statusColor(for: status))
                    .frame(width: size.statusSize, height: size.statusSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white0, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    // MARK: - Computed Properties

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var avatarColor: Color {
        let colors: [Color] = [.green5, .green4, .green6, .orange2, .gray5]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    private func statusColor(for status: UserStatus) -> Color {
        switch status {
        case .online:
            return .mainColor
        case .away:
            return .orange2
        case .busy:
            return .error
        case .offline:
            return .gray4
        }
    }
}
