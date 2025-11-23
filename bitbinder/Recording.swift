//
//  Recording.swift
//  bitbinder
//
//  Created by taylor drew on 11/22/25.
//

import Foundation
import SwiftData

@Model
final class Recording: Identifiable {
    @Attribute(.unique) var id: UUID
    var setListId: UUID
    var setListName: String
    var fileURL: URL
    var durationSec: TimeInterval
    var createdAt: Date
    var notes: String?

    init(setListId: UUID, setListName: String, fileURL: URL, durationSec: TimeInterval) {
        self.id = UUID()
        self.setListId = setListId
        self.setListName = setListName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fileURL = fileURL
        self.durationSec = durationSec
        self.createdAt = Date()
        self.notes = nil
    }

    func addNotes(_ text: String) {
        self.notes = text.isEmpty ? nil : text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
