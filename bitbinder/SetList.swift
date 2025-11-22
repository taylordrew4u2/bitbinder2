//
//  SetList.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import Foundation
import SwiftData

@Model
final class SetList {
    @Attribute(.unique) var id: UUID
    var name: String
    var jokeOrder: [UUID] // Array of Joke IDs in order
    var createdAt: Date
    var updatedAt: Date
    var lastPerformedAt: Date?
    
    init(name: String, jokeOrder: [UUID] = []) {
        self.id = UUID()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.jokeOrder = jokeOrder
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateName(_ newName: String) {
        self.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = Date()
    }
    
    func updateJokeOrder(_ newOrder: [UUID]) {
        self.jokeOrder = newOrder
        self.updatedAt = Date()
    }
}
