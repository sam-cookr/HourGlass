import SwiftData
import Foundation

@Model
final class TimeEntry {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var notes: String?
    var job: Job?
    var isBillable: Bool
    var customRate: Double?

    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }

    var effectiveRate: Double {
        customRate ?? job?.hourlyRate ?? 0.0
    }

    var earnings: Double {
        (duration / 3600) * effectiveRate
    }

    init(startTime: Date = .now, endTime: Date? = nil, notes: String? = nil, job: Job? = nil, isBillable: Bool = true, customRate: Double? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.job = job
        self.isBillable = isBillable
        self.customRate = customRate
    }
}
