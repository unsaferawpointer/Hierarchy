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

	private var animator = HierarchyAnimator()

	var dropConfiguration: DropConfiguration? {
		didSet {
			table?.unregisterDraggedTypes()
			table?.registerForDraggedTypes(dropConfiguration?.types ?? [])
		}
	}

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

		configureView(view, with: model)

		return view
	}
}

// MARK: - Drag & Drop
extension HierarchyTableAdapter {

	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		guard let item = item as? ListItem else {
			return nil
		}
		let pasteboardItem = NSPasteboardItem()
		pasteboardItem.setString(item.uuid.uuidString, forType: .id)
		return pasteboardItem
	}

	func outlineView(
		_ outlineView: NSOutlineView,
		validateDrop info: NSDraggingInfo,
		proposedItem item: Any?,
		proposedChildIndex index: Int
	) -> NSDragOperation {
		guard let dropConfiguration else {
			return []
		}
		let destination = getDestination(proposedItem: item, proposedChildIndex: index)
		let identifiers = getIdentifiers(from: info)
		return dropConfiguration.invalidate?(identifiers, destination) ?? true ? .move : []
	}

	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		let destination = getDestination(proposedItem: item, proposedChildIndex: index)
		let identifiers = getIdentifiers(from: info)
		dropConfiguration?.onDrop?(identifiers, destination)
		return true
	}
}

// MARK: - Helpers
extension HierarchyTableAdapter {

	func getDestination(proposedItem item: Any?, proposedChildIndex index: Int) -> HierarchyDestination {
		switch (item, index) {
		case (.none, -1):
			return .toRoot
		case (.none, let index):
			return .inRoot(atIndex: index)
		case (let item as ListItem, -1):
			return .onItem(with: item.uuid)
		case (let item as ListItem, let index):
			return .inItem(with: item.uuid, atIndex: index)
		default:
			fatalError()
		}
	}

	func getIdentifiers(from info: NSDraggingInfo) -> [UUID] {
		guard let pasteboardItems = info.draggingPasteboard.pasteboardItems else {
			return []
		}
		return pasteboardItems.compactMap { item in
			item.string(forType: .id)
		}.compactMap { string in
			UUID(uuidString: string)
		}
	}

	func configureRow(with model: HierarchyModel, at row: Int) {
		let view = table?.view(atColumn: 0, row: row, makeIfNecessary: false) as? HierarchyItemView
		configureView(view, with: model)
	}

	func configureView(_ view: HierarchyItemView?, with model: HierarchyModel) {
		view?.text = model.text
		view?.iconName = model.icon
		view?.style = model.style
		view?.status = model.status
		view?.isFavorite = model.isFavorite

		view?.statusDidChange = model.statusDidChange
		view?.textDidChange = model.textDidChange
	}
}

extension NSPasteboard.PasteboardType {

	static let id = NSPasteboard.PasteboardType("com.paperwave.hierarchy.item-id")
}
