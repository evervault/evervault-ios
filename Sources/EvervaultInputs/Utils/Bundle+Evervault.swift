import Foundation

extension Bundle {
    static var evervaultInputs: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        let bundleURL = Bundle(for: BundleLocator.self)
            .url(forResource: "EvervaultInputs", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init) ?? Bundle(for: BundleLocator.self)
        #endif
    }
}

private class BundleLocator {}
