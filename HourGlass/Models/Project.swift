//
//  Project.swift
//  OTC
//
//  Created by Sam Cook on 08/06/2025.
//

import SwiftData
import Foundation

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var projectDescription: String?
    var dateCreated: Date
    var updatedAt: Date?
    var isCompleted: Bool
    var deadline: Date?

    @Relationship(deleteRule: .cascade, inverse: \Job.parentProject)
    var jobs: [Job]?

    init(name: String, projectDescription: String? = nil, dateCreated: Date = .now, isCompleted: Bool = false, deadline: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.projectDescription = projectDescription
        self.dateCreated = dateCreated
        self.isCompleted = isCompleted
        self.deadline = deadline
    }
}
