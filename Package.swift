// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cookly",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Un proyecto de xtool tiene exactamente un producto "library": la app.
        .library(
            name: "Cookly",
            targets: ["Cookly"]
        ),
    ],
    targets: [
        .target(
            name: "Cookly",
            // Modo Swift 5: evita que los chequeos estrictos de concurrencia de Swift 6
            // bloqueen la compilación por detalles que no afectan esta app.
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
