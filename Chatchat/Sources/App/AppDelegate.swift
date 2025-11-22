//
//  AppDelegate.swift
//  Chatchat
//
//  Created by Youjin Lee on 11/15/25.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerFonts()
        setupDependencies()
        return true
    }

    private func registerFonts() {
        ChatchatFontFamily.registerAllCustomFonts()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let socketClient = DIContainer.shared.resolveOptional(SocketClientProtocol.self)
        socketClient?.disconnect()
    }

    private func setupDependencies() {
        AppAssembler.assemble()
    }
}
