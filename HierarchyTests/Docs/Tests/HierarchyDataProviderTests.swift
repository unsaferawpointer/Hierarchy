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
		let expected = HierarchyContent(id: try XCTUnwrap(UUID(uuidString: "B93C2453-D274-48B3-A4CB-B4634E9FB41E")), hierarchy: [])

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
		encoder.outputFormatting = .prettyPrinted
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
		return .init(id: UUID(uuidString: "B93C2453-D274-48B3-A4CB-B4634E9FB41E")!, hierarchy:
					[
						.section(uuid: UUID(uuidString: "DD937754-3463-4B0B-B6DB-9AF14B18B8C0")!, icon: "folder", text: "It is section", items:
									[
										.list(uuid: UUID(uuidString: "BAF077D9-BDD8-40A8-8348-B3BA50145992")!, icon: "doc", text: "It is list", todos:
												[
													.init(uuid: UUID(uuidString: "9A7EB176-7FF3-4C99-B1D0-F25D4125B0CF")!, text: "Todo 0"),
													.init(uuid: UUID(uuidString: "F7BED912-2237-412B-B470-B72DC3703FDC")!, text: "Todo 1")
												]
											 )
									]
								),
						.list(uuid: UUID(uuidString: "4BF8637E-7B35-45B5-9111-E5E259535A4C")!, icon: "doc", text: "It is list", todos:
								[
									.init(uuid: UUID(uuidString: "BAE4F11F-5B60-4F10-90AE-741067F81DD7")!, text: "Todo 0"),
									.init(uuid: UUID(uuidString: "A106B353-937E-4CA4-9B36-B73FC96266D5")!, text: "Todo 1")
								]
							 )
					]
		)
	}
}
