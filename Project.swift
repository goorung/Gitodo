import ProjectDescription

private let appName = "Gitodo"
private let bundleId = "com.goorung.Gitodo"
private let bundleShortVersionString = "1.0.0"
private let bundleVersion = "1"
private let deploymentTarget = "17.0"

private let appInfoPlist = InfoPlist.extendingDefault(with: [
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "CFBundleDisplayName": .string(appName),
    "CFBundleName": .string(appName),
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
    "CFBundleDisplayName": .string(appName),
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
    name: "Gitodo",
    targets: [
        // Shared Framework target
        .target(
            name: "\(appName)Shared",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "\(bundleId).Shared",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: .default,
            sources: ["\(appName)Shared/Sources/**"],
            resources: [],
            dependencies: [.external(name: "RealmSwift", condition: .none)]
        ),
        // App target
        .target(
            name: appName,
            destinations: [.iPhone],
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: appInfoPlist,
            sources: ["\(appName)/Sources/**"],
            resources: ["\(appName)/Resources/**"],
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
            bundleId: "\(bundleId).RepoListWidget",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: widgetInfoPlist,
            sources: ["Widgets/RepoListWidget/Sources**"],
            resources: ["Widgets/RepoListWidget/Resources/**"]
        ),
        // Medium Intent Widget target
        .target(
            name: "GitodoRepoTodoWidget",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "\(bundleId).RepoTodoWidget",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: widgetInfoPlist,
            sources: ["Widgets/RepoTodoWidget/Sources**"],
            resources: ["Widgets/RepoTodoWidget/Resources/**"]
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
