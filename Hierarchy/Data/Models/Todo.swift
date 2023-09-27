//
//  Todo.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

struct Todo { 

	var uuid: UUID

	var text: String
}

// MARK: - Codable
extension Todo: Codable { }

// MARK: - Equatable
extension Todo: Equatable { }
