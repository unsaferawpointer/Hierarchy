//
//  HierarchyDestination.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 07.10.2023.
//

import Foundation

enum HierarchyDestination {

	case toRoot
	case inRoot(atIndex: Int)
	case onItem(with: UUID)
	case inItem(with: UUID, atIndex: Int)

	var id: UUID? {
		switch self {
		case .toRoot, .inRoot:
			return nil
		case .onItem(let id), .inItem(let id, _):
			return id
		}
	}

	var index: Int? {
		switch self {
		case .toRoot:
			return nil
		case .inRoot(let index):
			return index
		case .onItem:
			return nil
		case .inItem(_ , let index):
			return index
		}
	}
}
