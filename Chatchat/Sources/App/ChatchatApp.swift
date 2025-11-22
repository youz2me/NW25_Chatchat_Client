//
//  ChatchatApp.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import SwiftUI

@main
struct ChatchatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let viewModelFactory = ViewModelFactory()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.viewModelFactory, viewModelFactory)
        }
    }
}
