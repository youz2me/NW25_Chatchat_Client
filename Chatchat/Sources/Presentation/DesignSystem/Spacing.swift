//
//  Spacing.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/19/25.
//

import SwiftUI

// MARK: - Spacing System (4pt Grid)

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 48
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xlarge: CGFloat = 16
    static let full: CGFloat = 9999
}

// MARK: - Component Sizes

enum ComponentSize {
    static let buttonLarge: CGFloat = 52
    static let buttonMedium: CGFloat = 44
    static let buttonSmall: CGFloat = 36
    
    static let textFieldHeight: CGFloat = 48
    static let avatarLarge: CGFloat = 48
    static let avatarMedium: CGFloat = 40
    static let avatarSmall: CGFloat = 32
    
    static let iconLarge: CGFloat = 24
    static let iconMedium: CGFloat = 20
    static let iconSmall: CGFloat = 16
}

// MARK: - View Modifiers

extension View {
    func horizontalPadding(_ spacing: CGFloat = Spacing.md) -> some View {
        self.padding(.horizontal, spacing)
    }

    func verticalPadding(_ spacing: CGFloat = Spacing.md) -> some View {
        self.padding(.vertical, spacing)
    }
}
