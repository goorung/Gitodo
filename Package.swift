// swift-tools-version:5.9
import PackageDescription

#if TUIST
import ProjectDescription


let packageSettings = PackageSettings(
    productTypes: [
        "SnapKit": .framework,
        "Kingfisher": .framework,
        "RxSwift": .framework,
        "RxGesture": .framework,
    ]
)
#endif


let package = Package(
    name: "Gitodo",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git",from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture", from: "4.0.0"),
        .package(url: "https://github.com/realm/realm-swift", exact: "10.49.2"),
    ]
)
    
