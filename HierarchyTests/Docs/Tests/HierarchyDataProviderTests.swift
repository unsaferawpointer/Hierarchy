//
//  HierarchyDataProviderTests.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import XCTest
@testable import Hierarchy

final class HierarchyDataProviderTests: XCTestCase {

	var sut: HierarchyDataProvider!

	override func setUpWithError() throws {
		sut = HierarchyDataProvider()
	}

	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - ContentProvider test-cases
extension HierarchyDataProviderTests {

	func test_read() throws {
		// Arrange
		let data = try loadFile(withName: "List_v1")

		// Act
		let result = try sut.read(from: data, ofType: "com.paperwave.hierarchy")

		// Assert
		XCTAssertEqual(result, expected)
	}

	func test_read_whenFileContainsMinimumRequiredProperties() throws {
		// Arrange
		let data = try loadFile(withName: "List_v1_minimum")
		let expected = HierarchyContent(id: try XCTUnwrap(.uuid0), hierarchy: [])

		// Act
		let result = try sut.read(from: data, ofType: "com.paperwave.hierarchy")

		// Assert
		XCTAssertEqual(result, expected)
	}

	func test_read_whenFormatIsInvalid() throws {
		// Arrange
		let data = try loadFile(withName: "List_v1_broken")

		// Act
		XCTAssertThrowsError(try sut.read(from: data, ofType: "com.paperwave.hierarchy"), "It is expected error") { error in
			XCTAssertEqual(error as? DocumentError, .unexpectedFormat)
		}
	}

	func test_read_whenNoVersion() throws {
		// Arrange
		let data = try loadFile(withName: "List_v1_no_version")

		// Act
		XCTAssertThrowsError(try sut.read(from: data, ofType: "com.paperwave.hierarchy"), "Expected error") { error in
			XCTAssertEqual(error as? DocumentError, .unexpectedFormat)
		}
	}

	func test_read_whenVersionIsInvalid() throws {
		// Arrange
		let data = try loadFile(withName: "List_v1_invalid_version")

		// Act
		XCTAssertThrowsError(try sut.read(from: data, ofType: "com.paperwave.hierarchy"), "Expected error") { error in
			XCTAssertEqual(error as? DocumentError, .unknownVersion)
		}
	}

	func test_data() throws {
		// Act
		let result = try sut.data(ofType: "com.paperwave.hierarchy", content: expected)

		// Assert
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		encoder.dateEncodingStrategy = .secondsSince1970

		let file = DocumentFile(version: "v1", content: expected)
		let expectedData = try encoder.encode(file)
		XCTAssertEqual(result, expectedData)
	}
}

// MARK: - Helpers
private extension HierarchyDataProviderTests {

	func loadFile(withName name: String) throws -> Data {
		let bundle = Bundle(for: HierarchyDataProviderTests.self)
		let path = try XCTUnwrap(bundle.path(forResource: name, ofType: "hierarchy"))
		return try XCTUnwrap(FileManager.default.contents(atPath: path))
	}
}

private extension HierarchyDataProviderTests {

	var expected: HierarchyContent {
		return .init(id: .uuid0, hierarchy: HierarchyMocks.containers)
	}
}
