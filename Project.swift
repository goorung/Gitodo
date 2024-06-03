import ProjectDescription

private let bundleId = "com.goorung.Gitodo"
private let bundleShortVersionString = "1.0.0"
private let bundleVersion = "1"
private let deploymentTarget = "17.0"

private let appInfoPlist = InfoPlist.extendingDefault(with: [
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "CFBundleDisplayName": .string("Gitodo!"),
    "CFBundleName": .string("Gitodo"),
    "CFBundleShortVersionString": .string(bundleShortVersionString),
    "CFBundleVersion": .string(bundleVersion),
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
    "UISupportedInterfaceOrientations":
    [
        "UIInterfaceOrientationPortrait",
    ],
    "CFBundleURLTypes": [
        [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["gitodo"]
        ]
    ],
    "CLIENT_ID": "$(CLIENT_ID)",
    "CLIENT_SECRET": "$(CLIENT_SECRET)"
])

private let widgetInfoPlist = InfoPlist.extendingDefault(with: [
    "CFBundleDisplayName": .string("Gitodo!"),
    "CFBundleIdentifier": .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
    "CFBundleInfoDictionaryVersion": .string("6.0"),
    "CFBundlePackageType": .string("XPC!"),
    "CFBundleShortVersionString": .string(bundleShortVersionString),
    "CFBundleVersion": .string(bundleVersion),
    "NSExtension": .dictionary([
        "NSExtensionPointIdentifier": .string("com.apple.widgetkit-extension")
    ])
])

private let appDependencies: [TargetDependency] = [
    .external(name: "SnapKit", condition: .none),
    .external(name: "Kingfisher", condition: .none),
    .external(name: "RxCocoa", condition: .none),
    .external(name: "RxSwift", condition: .none),
    .external(name: "RxGesture", condition: .none),
    .external(name: "SwiftyToaster", condition: .none),
    .external(name: "MarkdownView", condition: .none),
    .external(name: "SkeletonView", condition: .none),
    .target(name: "GitodoShared", condition: .none),
    .target(name: "GitodoRepoListWidget", condition: .none),
    .target(name: "GitodoRepoTodoWidget", condition: .none),
]

private let widgetDependencies: [TargetDependency] = [
    .target(name: "GitodoShared", condition: .none),
]

let project = Project(
    name: "Gitodo!",
    targets: [
        // Shared Framework target
        .target(
            name: "GitodoShared",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "\(bundleId).Shared",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: .default,
            sources: ["GitodoShared/Sources/**"],
            resources: ["GitodoShared/Resources/**"],
            dependencies: [.external(name: "RealmSwift", condition: .none)]
        ),
        // App target
        .target(
            name: "Gitodo",
            destinations: [.iPhone],
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: appInfoPlist,
            sources: ["Gitodo/Sources/**"],
            resources: ["Gitodo/Resources/**"],
            entitlements: "Gitodo.entitlements",
            dependencies: appDependencies,
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configurations/secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Configurations/secrets.xcconfig")
                ]
            )
        ),
        // Small Static Widget target
        .target(
            name: "GitodoRepoListWidget",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "\(bundleId).RepoList",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: widgetInfoPlist,
            sources: ["Widgets/RepoList/Sources**"],
            resources: ["Widgets/RepoList/Resources/**"],
            entitlements: "Gitodo.entitlements",
            dependencies: widgetDependencies
        ),
        // Medium Intent Widget target
        .target(
            name: "GitodoRepoTodoWidget",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "\(bundleId).RepoTodo",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: widgetInfoPlist,
            sources: ["Widgets/RepoTodo/Sources**"],
            resources: ["Widgets/RepoTodo/Resources/**"],
            entitlements: "Gitodo.entitlements",
            dependencies: widgetDependencies
        ),
    ]
)
