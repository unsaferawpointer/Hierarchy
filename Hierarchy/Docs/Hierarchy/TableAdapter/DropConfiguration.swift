//
//  DropConfiguration.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 04.10.2023.
//

import Cocoa

struct DropConfiguration {

	var types: [NSPasteboard.PasteboardType] = []

	var onDrop: (([UUID], HierarchyDestination) -> Void)?

	var invalidate: (([UUID], HierarchyDestination) -> Bool)?
}
