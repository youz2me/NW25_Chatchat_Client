//
//  NavigationRouter.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/20/25.
//

import SwiftUI

enum Route: Hashable {
    case login
    case register
    case findPassword
    case roomList
    case chatRoom(ChatRoomEntity)
}

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func replace(with route: Route) {
        path = NavigationPath()
        path.append(route)
    }
}
