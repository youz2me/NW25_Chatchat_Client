//
//  Colors.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

// MARK: - App Colors

extension Color {

    // MARK: - Main Color
    
    static let mainColor = Color(hex: "0FD360")

    // MARK: - Green Scale

    static let green1 = Color(hex: "E7FAEF")
    static let green2 = Color(hex: "B5F0CD")
    static let green3 = Color(hex: "83E6AB")
    static let green4 = Color(hex: "51DC89")
    static let green5 = Color(hex: "0FD360")
    static let green6 = Color(hex: "0BA94D")

    // MARK: - Gray Scale

    static let white0 = Color(hex: "FFFFFF")
    static let gray1 = Color(hex: "F5F5F5")
    static let gray2 = Color(hex: "E8E8E8")
    static let gray3 = Color(hex: "BDBDBD")
    static let gray4 = Color(hex: "9E9E9E")
    static let gray5 = Color(hex: "757575")
    static let gray6 = Color(hex: "616161")
    static let gray7 = Color(hex: "424242")
    static let gray8 = Color(hex: "212121")
    static let black0 = Color(hex: "000000")

    // MARK: - Orange Scale

    static let orange1 = Color(hex: "FFEDE5")
    static let orange2 = Color(hex: "FF8A50")
    static let orange3 = Color(hex: "FF5722")

    // MARK: - Semantic Colors

    static let textPrimary = gray8
    static let textSecondary = gray5
    static let textTertiary = gray4
    static let textPlaceholder = gray3

    static let backgroundPrimary = white0
    static let backgroundSecondary = gray1
    static let backgroundTertiary = gray2

    static let borderDefault = gray2
    static let borderFocused = mainColor

    static let success = mainColor
    static let warning = orange2
    static let error = orange3
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
