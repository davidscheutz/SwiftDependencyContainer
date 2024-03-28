import XCTest
@testable import SwiftDependencyContainerDemo

final class SwiftDependencyContainerDemoTests: XCTestCase {

    func test_resolveRegisteredSingletons() throws {
        try Dependencies.verifyResolvability()
    }
}
