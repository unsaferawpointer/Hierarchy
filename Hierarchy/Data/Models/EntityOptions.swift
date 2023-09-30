//
//  EntityOptions.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Foundation

struct EntityOptions: OptionSet {

	var rawValue: Int16

	static let checkbox = EntityOptions(rawValue: 1 << 0)
	static let badge = EntityOptions(rawValue: 1 << 2)
}

// MARK: - Codable
extension EntityOptions: Codable { }
