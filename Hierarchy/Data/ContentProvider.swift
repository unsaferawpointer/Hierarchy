//
//  ContentProvider.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

/// Data provider interface
protocol ContentProvider<Content> {

	associatedtype Content

	/// - Returns: Data of the content
	func data(ofType typeName: String, content: Content) throws -> Data

	/// - Returns content from data
	func read(from data: Data, ofType typeName: String) throws -> Content
}
