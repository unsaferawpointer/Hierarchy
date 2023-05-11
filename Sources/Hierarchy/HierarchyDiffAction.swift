//
//  HierarchyDiffAction.swift
//  
//
//  Created by Anton Cherkasov on 10.05.2023.
//

import Foundation

public enum HierarchyDiffAction<Item: ReferenceIdentifiable> {
	case updateItem(_ item: Item?)
	case removeItems(atIndexes: IndexSet, inParent: Item?)
	case insertItems(atIndexes: IndexSet, inParent: Item?)
}

// MARK: - Equatable
extension HierarchyDiffAction: Equatable {

	public static func == (lhs: HierarchyDiffAction<Item>, rhs: HierarchyDiffAction<Item>) -> Bool {
		switch (lhs, rhs) {
			case (.updateItem(let lhsItem), .updateItem(let rhsItem)):
				return lhsItem?.id == rhsItem?.id
			case (.insertItems(let lhsIndexes, let lhsParent), .insertItems(let rhsIndexes, let rhsParent)):
				return lhsIndexes == rhsIndexes && lhsParent?.id == rhsParent?.id
			case (.removeItems(let lhsIndexes, let lhsParent), .removeItems(let rhsIndexes, let rhsParent)):
				return lhsIndexes == rhsIndexes && lhsParent?.id == rhsParent?.id
			default:
				return false
		}
	}
}
