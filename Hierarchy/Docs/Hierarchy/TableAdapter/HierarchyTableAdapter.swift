//
//  HierarchyTableAdapter.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Cocoa

final class ListItem {

	var uuid: UUID

	init(uuid: UUID) {
		self.uuid = uuid
	}
}

final class HierarchyTableAdapter: NSObject {

	weak var table: NSOutlineView?

	var animator = HierarchyAnimator()

	// MARK: - Data

	var snapshot: HierarchySnapshot = .init()

	var cache: [UUID: ListItem] = [:]

	// MARK: - Initialization

	init(table: NSOutlineView) {
		self.table = table
		super.init()

		table.delegate = self
		table.dataSource = self
	}
}

// MARK: - Public interface
extension HierarchyTableAdapter {

	func apply(_ new: HierarchySnapshot) {
		var old = snapshot

		let intersection = old.identifiers.intersection(new.identifiers)

		for id in intersection {
			let item = cache[unsafe: id]
			let model = new.model(with: id)
			guard let row = table?.row(forItem: item), row != -1 else {
				continue
			}
			configureRow(with: model, at: row)
		}


		table?.beginUpdates()
		let (deleted, inserted) = animator.calculate(old: snapshot, new: new)
		for id in deleted {
			cache[id] = nil
		}
		for id in inserted {
			cache[id] = ListItem(uuid: id)
		}

		self.snapshot = new
		animator.calculate(old: old, new: new) { [weak self] animation in
			guard let self else {
				return
			}
			switch animation {
			case .remove(let offset, let parent):
				let item = cache[parent]
				let rows = IndexSet(integer: offset)
				table?.removeItems(
					at: rows,
					inParent: item,
					withAnimation: [.effectFade, .slideLeft]
				)
			case .insert(let offset, let parent):
				let destination = cache[parent]
				let rows = IndexSet(integer: offset)
				table?.insertItems(
					at: rows,
					inParent: destination,
					withAnimation: [.effectFade, .slideRight]
				)
			case .reload(let id):
				guard let item = cache[id] else {
					return
				}
				table?.reloadItem(item)
			}
		}
		table?.endUpdates()
	}

	func configureRow(with model: HierarchyModel, at row: Int) {
		let view = table?.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyItemView

		view?.text = model.text
		view?.iconName = model.icon
		view?.options = model.options
		view?.status = model.status

		view?.statusDidChange = model.statusDidChange
		view?.textDidChange = model.textDidChange
	}
}

// MARK: - NSOutlineViewDataSource
extension HierarchyTableAdapter: NSOutlineViewDataSource {

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard 
			let item = item as? ListItem
		else {
			let id = snapshot.rootItem(at: index).uuid
			return cache[unsafe: id]
		}
		let id = snapshot.childOfItem(item.uuid, at: index).uuid
		return cache[unsafe: id]
	}

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard 
			let item = item as? ListItem
		else {
			return snapshot.numberOfRootItems()
		}
		return snapshot.numberOfChildren(ofItem: item.uuid)
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let item = item as? ListItem else {
			return false
		}
		return snapshot.numberOfChildren(ofItem: item.uuid) > 0
	}
}

// MARK: - NSOutlineViewDelegate
extension HierarchyTableAdapter: NSOutlineViewDelegate {

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let item = item as? ListItem else {
			return nil
		}

		let model = snapshot.model(with: item.uuid)

		let id = NSUserInterfaceItemIdentifier(HierarchyItemView.reuseIdentifier)
		var view = table?.makeView(withIdentifier: id, owner: self) as? HierarchyItemView
		if view == nil {
			view = HierarchyItemView()
			view?.identifier = id
		}

		view?.text = model.text
		view?.iconName = model.icon
		view?.options = model.options
		view?.status = model.status

		view?.statusDidChange = model.statusDidChange
		view?.textDidChange = model.textDidChange

		return view
	}
}
