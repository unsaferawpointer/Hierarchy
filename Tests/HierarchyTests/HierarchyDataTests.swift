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

// MARK: - Insertion test-cases
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

// MARK: - Removing test-cases
extension HierarchyDataTests {

	func test_remove() {
		/*
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		sut.remove([item10, item12, item121])

		// Assert
		XCTAssertEqual(sut.root, [root0.id, root1.id, root2.id])

		XCTAssertEqual(sut.storage.count, 4)
		XCTAssertIdentical(sut.storage[root0.id], root0)
		XCTAssertIdentical(sut.storage[root1.id], root1)
		XCTAssertIdentical(sut.storage[root2.id], root2)
		XCTAssertIdentical(sut.storage[item11.id], item11)

		XCTAssertEqual(sut.hierarchy.count, 4)
		XCTAssertEqual(sut.hierarchy, [root0.id:	[],
									   root1.id:	[item11.id],
									   root2.id:	[],
									   item11.id:	[]])

		XCTAssertEqual(sut.parents.count, 1)
		XCTAssertEqual(sut.parents, [item11.id : root1.id])
	}
}

// MARK: Diff test-cases
extension HierarchyDataTests {

	func test_diff() {
		// Arrange
		/*
		 Before:
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2

		 After:
		 - 0
		 - 1
			- 10
				- insertingItem
			- 12
				- 120
		 - insertingRoot
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		let insertingRoot = ObjectMock(value: "insertingRoot")
		let insertingItem = ObjectMock(value: "insertingItem")

		// Act
		sut.startUpdating()
		sut.remove([item11, item121])
		sut.insert([insertingRoot], at: 2)
		sut.insert([insertingItem], to: item10, at: nil)

		let operations = sut.endUpdating()

		// Assert
		XCTAssertEqual(operations, [.updateItem(nil),
									.insertItems(atIndexes: .init(integer: 2), inParent: nil),
									.updateItem(root1),
									.removeItems(atIndexes: .init(integer: 1), inParent: root1),
									.updateItem(item10),
									.insertItems(atIndexes: .init(integer: 0), inParent: item10),
									.updateItem(item12),
									.removeItems(atIndexes: .init(integer: 1), inParent: item12)])
		XCTAssertNil(sut.oldSnapshot)

	}
}

// MARK: - Moving test-cases
extension HierarchyDataTests {

	func test_move_toRoot() {
		// Arrange
		/*
		 Before:
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2

		 After:
		 - 1
			- 11
		 - 2
		 - 0
		 - 10
		 - 12
			- 120
		 - 121
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		sut.move([root0, item10, item12, item121], to: nil)

		// Assert
		XCTAssertEqual(sut.root, [root1.id, root2.id, root0.id, item10.id, item12.id, item121.id])

		XCTAssertEqual(sut.hierarchy[root0.id], [])
		XCTAssertEqual(sut.hierarchy[root1.id], [item11.id])
		XCTAssertEqual(sut.hierarchy[root2.id], [])
		XCTAssertEqual(sut.hierarchy[item10.id], [])
		XCTAssertEqual(sut.hierarchy[item12.id], [item120.id])
		XCTAssertEqual(sut.hierarchy[item121.id], [])
		XCTAssertEqual(sut.hierarchy.count, 8)

		XCTAssertEqual(sut.parents.count, 2)
		XCTAssertEqual(sut.parents[item120.id], item12.id)
		XCTAssertEqual(sut.parents[item11.id], root1.id)

		XCTAssertEqual(sut.storage.count, 8)
	}

	func test_move_toTarget() {
		// Arrange
		/*
		 Before:
		 - 0 x
		 - 1
			- 10 x
			- 11
			- 12 x
				- 120
				- 121 x
		 - 2

		 After:
		 - 1
			- 11
				- 0
				- 10
				- 12
					- 120
				- 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		sut.move([root0, item10, item12, item121], to: item11)

		// Assert
		XCTAssertEqual(sut.root, [root1.id, root2.id])

		XCTAssertEqual(sut.hierarchy[root1.id], [item11.id])
		XCTAssertEqual(sut.hierarchy[root2.id], [])
		XCTAssertEqual(sut.hierarchy[item11.id], [root0.id, item10.id, item12.id, item121.id])
		XCTAssertEqual(sut.hierarchy[root0.id], [])
		XCTAssertEqual(sut.hierarchy[item10.id], [])
		XCTAssertEqual(sut.hierarchy[item12.id], [item120.id])
		XCTAssertEqual(sut.hierarchy[item120.id], [])
		XCTAssertEqual(sut.hierarchy[item121.id], [])
		XCTAssertEqual(sut.hierarchy.count, 8)

		XCTAssertEqual(sut.parents.count, 6)
		XCTAssertEqual(sut.parents[item11.id], root1.id)
		XCTAssertEqual(sut.parents[root0.id], item11.id)
		XCTAssertEqual(sut.parents[item10.id], item11.id)
		XCTAssertEqual(sut.parents[item12.id], item11.id)
		XCTAssertEqual(sut.parents[item121.id], item11.id)
		XCTAssertEqual(sut.parents[item120.id], item12.id)

		XCTAssertEqual(sut.storage.count, 8)
	}

	func test_move_toTargetAtIndex() {
		// Arrange
		/*
		 Before:
		 - 0 x
		 - 1
			- 10 x
			- 11
			- 12 x
				- 120
				- 121 x
		 - 2

		 After:
		 - 1
			- 11
			- 0 x
			- 10 x
			- 12 x
				- 120
			- 121 x
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		sut.move([root0, item10, item12, item121], to: root1, at: 2)

		// Assert
		XCTAssertEqual(sut.root, [root1.id, root2.id])

		XCTAssertEqual(sut.hierarchy.count, 8)
		XCTAssertEqual(sut.hierarchy[root1.id], [item11.id, root0.id, item10.id, item12.id, item121.id])
		XCTAssertEqual(sut.hierarchy[item11.id], [])
		XCTAssertEqual(sut.hierarchy[root0.id], [])
		XCTAssertEqual(sut.hierarchy[item10.id], [])
		XCTAssertEqual(sut.hierarchy[item12.id], [item120.id])
		XCTAssertEqual(sut.hierarchy[item120.id], [])
		XCTAssertEqual(sut.hierarchy[item121.id], [])
		XCTAssertEqual(sut.hierarchy[root2.id], [])

		XCTAssertEqual(sut.parents.count, 6)
		XCTAssertEqual(sut.parents[item11.id], root1.id)
		XCTAssertEqual(sut.parents[root0.id], root1.id)
		XCTAssertEqual(sut.parents[item10.id], root1.id)
		XCTAssertEqual(sut.parents[item12.id], root1.id)
		XCTAssertEqual(sut.parents[item121.id], root1.id)
		XCTAssertEqual(sut.parents[item120.id], item12.id)

		XCTAssertEqual(sut.storage.count, 8)
	}

	func test_move_toRootAtIndex() {
		// Arrange
		/*
		 Before:
		 - 0 x
		 - 1
			- 10 x
			- 11
			- 12 x
				- 120
				- 121 x
		 - 2

		 After:
		 - 1
			- 11
		 - 0 x
		 - 10 x
		 - 12 x
			- 120
		 - 121 x
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		sut.moveToRoot([root0, item10, item12, item121], at: 2)

		// Assert
		XCTAssertEqual(sut.root, [root1.id, root0.id, item10.id, item12.id, item121.id, root2.id])

		XCTAssertEqual(sut.hierarchy.count, 8)
		XCTAssertEqual(sut.hierarchy[root1.id], [item11.id])
		XCTAssertEqual(sut.hierarchy[root0.id], [])
		XCTAssertEqual(sut.hierarchy[item10.id], [])
		XCTAssertEqual(sut.hierarchy[item12.id], [item120.id])
		XCTAssertEqual(sut.hierarchy[item120.id], [])
		XCTAssertEqual(sut.hierarchy[item121.id], [])
		XCTAssertEqual(sut.hierarchy[root2.id], [])

		XCTAssertEqual(sut.parents.count, 2)
		XCTAssertEqual(sut.parents[item11.id], root1.id)
		XCTAssertEqual(sut.parents[item120.id], item12.id)

		XCTAssertEqual(sut.storage.count, 8)
	}

	func test_canMoveToRoot_whenResultIsPositive() {
		// Arrange
		/*
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		let result = sut.canMove([item10, item12], to: nil)

		// Assert
		XCTAssertTrue(result)
	}

	func test_canMoveToTarget_whenResultIsPositive() {
		// Arrange
		/*
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		let result = sut.canMove([root1, item10, item12], to: item120)

		// Assert
		XCTAssertFalse(result)
	}

	func test_canMoveToTarget_whenResultIsNegative() {
		// Arrange
		/*
		 - 0
		 - 1
			- 10
			- 11
			- 12
				- 120
				- 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		let result = sut.canMove([root1, item11], to: item121)

		// Assert
		XCTAssertFalse(result)
	}

	func test_canMoveToItself() {
		// Arrange
		/*
		 - 0
		 - 1
		 - 10
		 - 11
		 - 12
		 - 120
		 - 121
		 - 2
		 */
		// Arrange
		let root0 = ObjectMock(value: "0")
		let root1 = ObjectMock(value: "1")
		let root2 = ObjectMock(value: "2")

		let item10 = ObjectMock(value: "1-0")
		let item11 = ObjectMock(value: "1-1")
		let item12 = ObjectMock(value: "1-2")

		let item120 =  ObjectMock(value: "1-2-0")
		let item121 =  ObjectMock(value: "1-2-1")

		sut.insert([root0, root1, root2], at: nil)
		sut.insert([item10, item11, item12], to: root1, at: nil)
		sut.insert([item120, item121], to: item12, at: nil)

		// Act
		let result = sut.canMove([root1, item11], to: root1)

		// Assert
		XCTAssertFalse(result)
	}
}

// MARK: - Nested data structs
extension HierarchyDataTests {

	final class ObjectMock: ReferenceIdentifiable {

		let value: String

		init(value: String){
			self.value = value
		}
	}
}
