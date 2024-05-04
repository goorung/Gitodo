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
                ])
            ]),
            sources: ["Gitodo/Sources/**"],
            resources: ["Gitodo/Resources/**"],
            dependencies: [
                .external(name: "SnapKit", condition: .none),
                .external(name: "Kingfisher", condition: .none)
            ]
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
