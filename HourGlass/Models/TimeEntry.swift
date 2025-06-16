//
//  TimeEntry.swift
//  OTC
//
//  Created by Sam Cook on 08/06/2025.
//
import SwiftData
import Foundation

@Model
final class TimeEntry {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var notes: String?
    var job: Job?

    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }

    init(startTime: Date = .now, endTime: Date? = nil, notes: String? = nil, job: Job? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.job = job
    }
}

