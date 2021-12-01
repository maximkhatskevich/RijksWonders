import XCTest
@testable import RijksWondersServices

class CollectionEndpointTests: XCTestCase {

    let sut = CollectionEndpoint()
}

// MARK: - Tests

extension CollectionEndpointTests {
    
    func test_defaults() {
        XCTAssertEqual(sut.culture, .en)
        XCTAssertNil(sut.p)
        XCTAssertNil(sut.ps)
    }
    
    func test_path() {
        // expect default cuture
        XCTAssertEqual(sut.path, "/api/en/collection")
    }
}
