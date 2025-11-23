//
//  Joke.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import Foundation
import SwiftData

@Model
final class Joke: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date

    init(title: String, body: String = "") {
        self.id = UUID()
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func update(title: String, body: String) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = Date()
    }
}
