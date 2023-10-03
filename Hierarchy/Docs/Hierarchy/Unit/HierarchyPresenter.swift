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
		let snapshot = makeSnapshot()
		view?.display(snapshot)
	}

	func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.deleteItems(with: .init(ids))
		}
	}

	func createNew(with selection: [UUID]) {
		let first = selection.first
		let itemContent = ItemContent(text: "New item", isDone: false, iconName: "app")
		storage.modificate { content in
			content.appendItems(with: [itemContent], to: first)
		}
	}
}

extension HierarchyPresenter {

	func makeSnapshot() -> HierarchySnapshot {
		let items = storage.state.hierarchy
		return HierarchySnapshot(items) { entity in
			HierarchyModel(
				uuid: entity.uuid,
				status: entity.effectiveStatus,
				text: entity.content.text,
				icon: entity.content.iconName,
				options: entity.options) { [weak self] newText in
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
						content.setStatus(newStatus, for: entity.uuid)
					}
				}
		}
	}
}
