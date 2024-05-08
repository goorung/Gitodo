// swift-tools-version:5.9
import PackageDescription

#if TUIST
import ProjectDescription


let packageSettings = PackageSettings(
    productTypes: [
        "SnapKit": .framework,
        "Kingfisher": .framework,
        "RxSwift": .framework,
    ]
)
#endif


let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
    ],
    targets: [
      .target(name: "PackageName", dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
    ]
)
