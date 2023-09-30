//
//  ItemContent.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Foundation

struct ItemContent {

	var text: String

	var isDone: Bool

	var iconName: String
}

// MARK: - Equatable
extension ItemContent: Equatable { }

// MARK: - Codable
extension ItemContent: Codable { }
