//
//  HierarchyDataTests.swift
//  
//
//  Created by Anton Cherkasov on 08.05.2023.
//

import XCTest
@testable import Hierarchy

final class HierarchyDataTests: XCTestCase {

	var sut: HierarchyData<ObjectMock>!

	override func setUpWithError() throws {
		sut = .init()
	}

	override func tearDownWithError() throws {
		sut = nil
	}

}

// MARK: - Test - cases
extension HierarchyDataTests {

	func test_insert_toRoot_whenIndexIsNil() {
		// Arrange
		let items = [ObjectMock(value: "0"), ObjectMock(value: "1"), ObjectMock(value: "2")]

		// Act
		sut.insert(items, at: nil)

		// Assert
		XCTAssertEqual(sut.root.count, 3)

		XCTAssertEqual(sut.storage.count, 3)
		XCTAssertIdentical(sut.storage[items[0].id], items[0])
		XCTAssertIdentical(sut.storage[items[1].id], items[1])
		XCTAssertIdentical(sut.storage[items[2].id], items[2])

		XCTAssertEqual(sut.hierarchy.count, 3)
		XCTAssertEqual(sut.hierarchy[items[0].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[items[1].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[items[2].id]?.count, 0)

		XCTAssertEqual(sut.parents.count, 0)
	}

	func test_insert_toRoot_whenIndexIsNotNil() {
		// Arrange
		let items = [ObjectMock(value: "0"), ObjectMock(value: "1"), ObjectMock(value: "2")]

		// Act
		sut.insert(items, at: 0)

		// Assert
		XCTAssertEqual(sut.root.count, 3)

		XCTAssertEqual(sut.storage.count, 3)
		XCTAssertIdentical(sut.storage[items[0].id], items[0])
		XCTAssertIdentical(sut.storage[items[1].id], items[1])
		XCTAssertIdentical(sut.storage[items[2].id], items[2])

		XCTAssertEqual(sut.hierarchy.count, 3)
		XCTAssertEqual(sut.hierarchy[items[0].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[items[1].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[items[2].id]?.count, 0)

		XCTAssertEqual(sut.parents.count, 0)
	}

	func test_insert_toTarget_whenIndexIsNil() {
		// Arrange
		let items = [ObjectMock(value: "0"), ObjectMock(value: "1"), ObjectMock(value: "2")]
		sut.insert(items, at: nil)

		let insertingItems = [ObjectMock(value: "1-0"), ObjectMock(value: "1-1"), ObjectMock(value: "1-2")]

		// Act
		sut.insert(insertingItems, to: items[1], at: nil)

		// Assert
		XCTAssertEqual(sut.root.count, 3)

		XCTAssertEqual(sut.storage.count, 6)

		XCTAssertEqual(sut.hierarchy.count, 6)
		XCTAssertEqual(sut.hierarchy[items[0].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[items[1].id], [insertingItems[0].id,
													insertingItems[1].id,
													insertingItems[2].id])
		XCTAssertEqual(sut.hierarchy[items[2].id]?.count, 0)

		XCTAssertEqual(sut.parents.count, 3)
	}

	func test_insert_toTarget_whenIndexIsNotNil() {
		// Arrange
		let root = [ObjectMock(value: "0"), ObjectMock(value: "1"), ObjectMock(value: "2")]
		sut.insert(root, at: nil)

		let subitems = [ObjectMock(value: "1-0"), ObjectMock(value: "1-1"), ObjectMock(value: "1-2")]
		sut.insert(subitems, to: root[1], at: nil)

		let insertingItems = [ObjectMock(value: "inserting-0"), ObjectMock(value: "inserting-1")]

		// Act
		sut.insert(insertingItems, to: root[1], at: 1)

		// Assert
		XCTAssertEqual(sut.root.count, 3)

		XCTAssertEqual(sut.storage.count, 8)

		XCTAssertEqual(sut.hierarchy.count, 8)
		XCTAssertEqual(sut.hierarchy[root[0].id]?.count, 0)
		XCTAssertEqual(sut.hierarchy[root[1].id], [subitems[0].id,
												   insertingItems[0].id,
												   insertingItems[1].id,
												   subitems[1].id,
												   subitems[2].id])
		XCTAssertEqual(sut.hierarchy[root[2].id]?.count, 0)

		XCTAssertEqual(sut.parents.count, 5)
		XCTAssertEqual(sut.parents[insertingItems[0].id], root[1].id)
		XCTAssertEqual(sut.parents[insertingItems[1].id], root[1].id)
		XCTAssertEqual(sut.parents[subitems[0].id], root[1].id)
		XCTAssertEqual(sut.parents[subitems[1].id], root[1].id)
		XCTAssertEqual(sut.parents[subitems[2].id], root[1].id)
	}
}

extension HierarchyDataTests {

	final class ObjectMock: ReferenceIdentifiable {

		let value: String

		init(value: String){
			self.value = value
		}
	}
}
