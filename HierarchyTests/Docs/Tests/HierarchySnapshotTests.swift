//
//  HierarchySnapshotTests.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import XCTest
@testable import Hierarchy

final class HierarchySnapshotTests: XCTestCase {

	var sut: HierarchySnapshot!

	override func setUpWithError() throws {
		sut = HierarchySnapshot()
	}

	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - ContentProvider test-cases
extension HierarchySnapshotTests {

	func test_initialization() throws {
		// Act
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Assert
		XCTAssertEqual(
			sut.root,
			[
				.init(uuid: .uuid1, text: "item 0", icon: "doc"),
				.init(uuid: .uuid3, text: "item 1", icon: "doc")
			]
		)

		XCTAssertEqual(
			sut.storage,
			[
				.uuid1: [.init(uuid: .uuid2, text: "item 00", icon: "doc")],
				.uuid2: [],
				.uuid3: []
			]
		)
	}

	func test_numberOfChildren() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.numberOfChildren(ofItem: .uuid1)

		// Assert
		XCTAssertEqual(result, 1)
	}

	func test_numberOfRootItems() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.numberOfRootItems()

		// Assert
		XCTAssertEqual(result, 2)
	}

	func test_rootItem() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.rootItem(at: 1)

		//Assert
		XCTAssertEqual(result, .init(uuid: .uuid3, text: "item 1", icon: "doc"))
	}

	func test_childOfItem() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.childOfItem(.uuid1, at: 0)

		// Assert
		XCTAssertEqual(result, .init(uuid: .uuid2, text: "item 00", icon: "doc"))
	}
}
