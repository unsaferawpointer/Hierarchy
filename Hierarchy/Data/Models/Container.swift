//
//  Container.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

indirect enum Container {
	case list(uuid: UUID, icon: String, text: String, todos: [Todo])
	case section(uuid: UUID, icon: String, text: String, items: [Self])
}

// MARK: - Codable
extension Container: Codable { }

// MARK: - Equatable
extension Container: Equatable { }
