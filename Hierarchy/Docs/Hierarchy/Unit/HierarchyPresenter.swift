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
		let itemContent = ItemContent(text: "New item", isDone: false, iconName: "app")
		let destination: HierarchyDestination = if let first {
			.onItem(with: first)
		} else {
			.toRoot
		}
		storage.modificate { content in
			content.insertItems(with: [itemContent], to: destination)
		}
	}

	func markAsCompleted(with selection: [UUID]) {
		storage.modificate { content in
			content.setStatus(true, for: selection)
		}
	}

	func markAsIncomplete(with selection: [UUID]) {
		storage.modificate { content in
			content.setStatus(false, for: selection)
		}
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
		let items = storage.state.hierarchy
		return HierarchySnapshot(items) { entity in
			HierarchyModel(
				uuid: entity.uuid,
				status: entity.effectiveStatus,
				text: entity.content.text,
				icon: entity.content.iconName,
				style: entity.items.count > 0 ? .list : .checkbox) { [weak self] newText in
					guard let self else {
						return
					}
					storage.modificate { content in
						content.setText(newText, for: entity.uuid)
					}
				} statusDidChange: { [weak self] newStatus in
					guard let self else {
						return
					}
					storage.modificate { content in
						content.setStatus(newStatus, for: [entity.uuid])
					}
				}
		}
	}
}
