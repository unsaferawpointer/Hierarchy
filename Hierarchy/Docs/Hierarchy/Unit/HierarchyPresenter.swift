//
//  HierarchyPresenter.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.10.2023.
//

import Foundation

protocol HierarchyPresenterProtocol {
	func deleteItems(_ ids: [UUID])
	func createNew(with selection: [UUID])
}

final class HierarchyPresenter {

	var storage: DocumentStorage<HierarchyContent>

	weak var view: HierarchyView?

	init(storage: DocumentStorage<HierarchyContent>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			guard let self else {
				return
			}
			let snapshot = makeSnapshot()
			self.view?.display(snapshot)
		}
	}
}

// MARK: - HierarchyPresenterProtocol
extension HierarchyPresenter: HierarchyViewOutput {

	func viewDidLoad() {
		view?.display(makeSnapshot())
		view?.setConfiguration(makeDropConfiguration())
	}

	func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.deleteItems(ids)
		}
	}

	func createNew(with selection: [UUID]) {
		let first = selection.first
		let id = UUID()
		let itemContent = ItemContent(uuid: id, text: "New item", isDone: false, iconName: nil, count: 0, options: [])
		let destination: HierarchyDestination = if let first {
			.onItem(with: first)
		} else {
			.toRoot
		}

		storage.modificate { content in
			content.insertItems(with: [itemContent], to: destination)
		}
		view?.scroll(to: id)
		if let first {
			view?.expand(first)
		}
		view?.focus(on: id)

	}

	func setState(_ flag: Bool, withSelection selection: [UUID]) {
		storage.modificate { content in
			content.setStatus(flag, for: selection)
		}
	}

	func setBookmark(_ flag: Bool, withSelection selection: [UUID]) {
		storage.modificate { content in
			content.setFavoriteFlag(flag, for: selection)
		}
	}

	func setEstimation(_ value: Int, withSelection selection: [UUID]) {
		storage.modificate { content in
			content.setEstimation(value, for: selection)
		}
	}

	func setIcon(_ value: String?, withSelection selection: [UUID]) {
		storage.modificate { content in
			content.setIcon(value, for: selection)
		}
	}

	func canUndo() -> Bool {
		storage.canUndo()
	}

	func canRedo() -> Bool {
		storage.canRedo()
	}

	func redo() {
		storage.redo()
	}

	func undo() {
		storage.undo()
	}

}

extension HierarchyPresenter {

	func makeDropConfiguration() -> DropConfiguration {
		var configuration = DropConfiguration()
		configuration.types = [.id]
		configuration.onDrop = { [weak self] ids, destination in
			guard let self else {
				return
			}
			storage.modificate { content in
				content.moveItems(with: ids, to: destination)
			}
		}
		configuration.invalidate = { [weak self] ids, destination in
			guard let self else {
				return false
			}
			return self.storage.state.validateMoving(ids, to: destination)
		}
		return configuration
	}

	func makeSnapshot() -> HierarchySnapshot {
		let items = storage.state.hierarchy.nodes
		return HierarchySnapshot(items) { entity in
			let menu = MenuItem(
				state:
					[
						"completed" : entity.reduce(\.isDone) ? .on : .off,
						"favorite" : entity.value.isFavorite ? .on : .off
					],
				validation:
					[
						"completed" : true,
						"favorite": true,
						"delete": true,
						"estimation": entity.children.count == 0
					]
			)

			let style: HierarchyModel.Style = {
				if entity.children.count > 0 {
					if let name = entity.value.iconName {
						return .icon(name)
					} else {
						return .list
					}
				} else {
					return .checkbox
				}
			}()

			return HierarchyModel(
				uuid: entity.value.uuid,
				status: entity.reduce(\.isDone),
				text: entity.value.text,
				style: style,
				isFavorite: entity.value.options.contains(.favorite),
				number: entity.reduce(\.count),
				menu: menu,
				animateIcon: false) { [weak self] newText in
					guard let self else {
						return
					}
					storage.modificate { content in
						content.setText(newText, for: entity.id)
					}
				} statusDidChange: { [weak self] newStatus in
					guard let self else {
						return
					}
					storage.modificate { content in
						content.setStatus(newStatus, for: [entity.id])
					}
				}
		}
	}
}
