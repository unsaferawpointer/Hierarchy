//
//  HierarchyDiffAction.swift
//  
//
//  Created by Anton Cherkasov on 10.05.2023.
//

import Foundation

public enum HierarchyDiffAction: Equatable {
	case updateItem(_ item: ObjectIdentifier?)
	case removeItems(atIndexes: IndexSet, inParent: ObjectIdentifier?)
	case insertItems(atIndexes: IndexSet, inParent: ObjectIdentifier?)
}
