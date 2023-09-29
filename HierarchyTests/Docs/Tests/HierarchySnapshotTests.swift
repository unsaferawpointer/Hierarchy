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
		sut = HierarchySnapshot([])
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
				.init(uuid: .uuid1, text: "It is section", icon: "folder"),
				.init(uuid: .uuid5, text: "It is list", icon: "doc")
			]
		)

		XCTAssertEqual(
			sut.storage,
			[
				.uuid1: [.init(uuid: .uuid2, text: "It is list", icon: "doc")],
				.uuid2: [.init(uuid: .uuid3, text: "Todo 0", icon: "app"), .init(uuid: .uuid4, text: "Todo 1", icon: "app")],
				.uuid5: [.init(uuid: .uuid6, text: "Todo 0", icon: "app"), .init(uuid: .uuid7, text: "Todo 1", icon: "app")]
			]
		)
	}

	func test_numberOfChildren() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.numberOfChildren(ofItem: .uuid2)

		// Assert
		XCTAssertEqual(result, 2)
	}

	func text_numberOfRootItems() {
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
		XCTAssertEqual(result, .init(uuid: .uuid5, text: "It is list", icon: "doc"))
	}

	func test_childOfItem() {
		// Arrange
		sut = HierarchySnapshot(HierarchyMocks.containers)

		// Act
		let result = sut.childOfItem(.uuid2, at: 1)

		// Assert
		XCTAssertEqual(result, .init(uuid: .uuid4, text: "Todo 1", icon: "app"))
	}
}
