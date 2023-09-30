//
//  HierarchyTableAdapter.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Cocoa

final class HierarchyTableAdapter: NSObject {

	var storage: DocumentStorage<HierarchyContent>

	weak var table: NSOutlineView?

	init(table: NSOutlineView, storage: DocumentStorage<HierarchyContent>) {
		self.table = table
		self.storage = storage
		super.init()

		table.delegate = self
		table.dataSource = self

		storage.addObservation(for: self) { [weak self] _, content in
			self?.table?.reloadData()
			for node in storage.state.hierarchy {
				self?.table?.expandItem(node)
			}
		}
	}
}

// MARK: - NSOutlineViewDataSource
extension HierarchyTableAdapter: NSOutlineViewDataSource {

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard let item = item as? ItemEntity else {
			return storage.state.hierarchy[index]
		}
		return item.items?[index]
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let item = item as? ItemEntity else {
			return storage.state.hierarchy.count
		}
		return item.items?.count ?? 0
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let item = item as? ItemEntity else {
			return storage.state.hierarchy.count > 0
		}
		return (item.items?.count ?? 0) > 0
	}
}

// MARK: - NSOutlineViewDelegate
extension HierarchyTableAdapter: NSOutlineViewDelegate {

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let item = item as? ItemEntity else {
			return nil
		}
		let id = NSUserInterfaceItemIdentifier(HierarchyItemView.reuseIdentifier)
		var view = table?.makeView(withIdentifier: id, owner: self) as? HierarchyItemView
		if view == nil {
			view = HierarchyItemView()
			view?.identifier = id
		}
		view?.text = item.content.text
		view?.iconName = item.content.iconName
		return view
	}
}

extension HierarchyTableAdapter {

	func reload() {
//		table?.reloadData()
	}
}
