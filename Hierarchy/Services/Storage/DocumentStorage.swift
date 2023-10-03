//
//  DocumentStorage.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

final class DocumentStorage<State> {

	private(set) var provider: any ContentProvider<State>

	private var observations = [(State) -> Bool]()

	private (set) var state: State {
		didSet {
			observations = observations.filter { $0(state) }
		}
	}

	// MARK: - Initialization

	/// Basic initialization
	///
	/// - Parameters:
	///    - initialState: Initial state
	///    - provider: Document file data provider
	init(initialState: State, provider: any ContentProvider<State>) {
		self.state = initialState
		self.provider = provider
	}
}

// MARK: - DocumentDataPublisher
extension DocumentStorage: DocumentDataPublisher {

	func modificate(_ block: (inout State) -> Void) {
		block(&state)
	}

	func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	) {

		handler(object, state)

		// Each observation closure returns a Bool that indicates
		// whether the observation should still be kept alive,
		// based on whether the observing object is still retained.
		observations.append { [weak object] value in
			guard let object = object else {
				return false
			}

			handler(object, value)
			return true
		}
	}
}

// MARK: - DocumentDataRepresentation
extension DocumentStorage: DocumentDataRepresentation {

	func data(ofType typeName: String) throws -> Data {
		try provider.data(ofType: typeName, content: state)
	}

	func read(from data: Data, ofType typeName: String) throws {
		self.state = try provider.read(from: data, ofType: typeName)
	}
}
