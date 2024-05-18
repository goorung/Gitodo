import ProjectDescription

let project = Project(
    name: "Gitodo",
    targets: [
        .target(
            name: "Gitodo",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.goorung.Gitodo",
            infoPlist: .extendingDefault(with: [
                "ITSAppUsesNonExemptEncryption": .boolean(false),
                "CFBundleDisplayName": .string("Gitodo"),
                "CFBundleName": .string("Gitodo"),
                "CFBundleShortVersionString": .string("1.0.0"),
                "CFBundleVersion": .string("1"),
                "UILaunchStoryboardName": .string("LaunchScreen"),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                    "UISceneConfigurations": .dictionary([
                        "UIWindowSceneSessionRoleApplication": .array([
                            .dictionary([
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                            ])
                        ])
                    ])
                ]),
                "CFBundleURLTypes": [
                    [
                        "CFBundleTypeRole": "Editor",
                        "CFBundleURLSchemes": ["gitodo"]
                    ]
                ],
                "CLIENT_ID": "$(CLIENT_ID)",
                "CLIENT_SECRET": "$(CLIENT_SECRET)"
            ]),
            sources: ["Gitodo/Sources/**"],
            resources: ["Gitodo/Resources/**"],
            dependencies: [
                .external(name: "SnapKit", condition: .none),
                .external(name: "Kingfisher", condition: .none),
                .external(name: "RxCocoa", condition: .none),
                .external(name: "RxSwift", condition: .none),
                .external(name: "RxGesture", condition: .none)
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configurations/secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Configurations/secrets.xcconfig")
                ]
            )
        ),
        //        .target(
        //            name: "GitodoTests",
        //            destinations: .iOS,
        //            product: .unitTests,
        //            bundleId: "io.tuist.GitodoTests",
        //            infoPlist: .default,
        //            sources: ["Gitodo/Tests/**"],
        //            resources: [],
        //            dependencies: [.target(name: "Gitodo")]
        //        ),
    ]
)
