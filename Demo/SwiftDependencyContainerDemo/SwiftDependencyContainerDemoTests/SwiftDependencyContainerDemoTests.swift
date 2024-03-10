import XCTest
@testable import SwiftDependencyContainerDemo

final class SwiftDependencyContainerDemoTests: XCTestCase {

    func test_dependenciesCodeGen() throws {
        // TODO: generate test function that resolves all dependencies
//        try Dependencies.test()
        
        let apiClient = Dependencies.api
        let authApi = Dependencies.authApi
        let userApi = Dependencies.userApi
        
        // TODO: figure out how to verify variable type
//        XCTAssertEqual(variableType(authApi), AuthApi.self)
//        XCTAssertEqual(variableType(userApi), UserApi.self)
        
        // Verify same instance
        XCTAssertTrue(apiClient === userApi)
        XCTAssertTrue(userApi === authApi)
        XCTAssertTrue(authApi === ApiClient.resolveAuthApi())
        XCTAssertTrue(userApi === ApiClient.resolveUserApi())
    }
}
