//
//  RootView.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import SwiftUI

/// 앱 루트 뷰
/// - 인증 상태에 따라 화면 분기
struct RootView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @StateObject private var router = NavigationRouter()
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
            } else {
                NavigationStack(path: $router.path) {
                    LoginView(viewModel: viewModelFactory.makeLoginViewModel())
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route)
                        }
                }
            }
        }
        .environmentObject(router)
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
            isLoggedIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            isLoggedIn = false
            router.popToRoot()
        }
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .login:
            LoginView(viewModel: viewModelFactory.makeLoginViewModel())
        case .register:
            RegisterView(viewModel: viewModelFactory.makeRegisterViewModel())
        case .findPassword:
            FindPasswordView(viewModel: viewModelFactory.makeFindPasswordViewModel())
        case .roomList:
            RoomListView(viewModel: viewModelFactory.makeRoomListViewModel())
        case .chatRoom(let room):
            ChatRoomView(viewModel: viewModelFactory.makeChatRoomViewModel(room: room))
        }
    }
}

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    var body: some View {
        RoomListView(viewModel: viewModelFactory.makeRoomListViewModel())
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}
