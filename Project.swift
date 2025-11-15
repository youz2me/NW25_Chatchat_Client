import ProjectDescription

let project = Project(
    name: "Chatchat",
    targets: [
        .target(
            name: "Chatchat",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Chatchat",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Chatchat/Sources/**"],
            resources: ["Chatchat/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ChatchatTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ChatchatTests",
            infoPlist: .default,
            sources: ["Chatchat/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Chatchat")]
        ),
    ]
)
