import SwiftData
import Foundation
import SwiftUI

@Model
class Job {
    var id: UUID
    var name: String
    var jobDescription: String?
    var dateCreated: Date
    var updatedAt: Date?
    var hourlyRate: Double
    var isCompleted: Bool
    var systemIconName: String = "briefcase"
    var colorTheme: JobColor
    
    static let iconOptions = [
        "briefcase", "person.2", "display", "wrench.and.screwdriver",
        "hammer", "building.2", "doc.text", "folder", "calendar",
        "clock", "timer", "stopwatch", "dollarsign.circle", "eurosign.circle",
        "chart.bar", "chart.pie", "desktopcomputer", "laptopcomputer",
        "server.rack", "pencil.and.ruler", "signature", "at",
        "person.3", "lightbulb", "target", "airplane.departure",
        "car", "shippingbox", "paintbrush.pointed", "briefcase.fill",
        "pencil", "highlighter", "paperclip", "link", "ruler",
        "book.closed", "creditcard", "tray.full", "archivebox",
        "printer", "scanner", "phone", "teletype", "mail",
        "location", "map", "pin", "network", "globe",
        "cpu", "memorychip", "lifepreserver", "graduationcap", "fork.knife",
        "camera", "scissors", "eyedropper", "wrench", "arrow.up.arrow.down"
    ]
    
    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.job)
    var timeEntries: [TimeEntry]? = []
    
    var parentProject: Project?
    
    init(id: UUID = UUID(), name: String, jobDescription: String? = nil, dateCreated: Date = Date(), updatedAt: Date? = nil, hourlyRate: Double = 0.0, isCompleted: Bool = false, colorTheme: JobColor) {
        self.id = id
        self.name = name
        self.jobDescription = jobDescription
        self.dateCreated = dateCreated
        self.updatedAt = updatedAt
        self.hourlyRate = hourlyRate
        self.isCompleted = isCompleted
        self.colorTheme = colorTheme
    }
    
    func changeIconName(_ newName: String) {
        self.systemIconName = newName
    }
    
    func toggleCompleted () {
        if self.isCompleted {
            self.isCompleted = false
        } else {
            self.isCompleted = true
        }
    }


    var totalLoggedTime: TimeInterval {
        timeEntries?.reduce(0) { $0 + $1.duration } ?? 0
    }


    var formattedTotalLoggedTime: String {
        let totalSeconds = Int(totalLoggedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var totalEarnings: Double {
        timeEntries?.filter { $0.isBillable }.reduce(0) { $0 + $1.earnings } ?? 0
    }
}


enum JobColor: String, Codable, CaseIterable {
    case slate, sage, mist, sand, rose, sky, terracotta, lavender, stone, indigo, teal, maroon, olive, coral

    var displayColor: Color {
        switch self {
        case .slate:
            return Color(red: 0.7, green: 0.75, blue: 0.8)
        case .sage:
            return Color(red: 0.7, green: 0.8, blue: 0.7)
        case .mist:
            return Color(red: 0.85, green: 0.85, blue: 0.9)
        case .sand:
            return Color(red: 0.9, green: 0.85, blue: 0.75)
        case .rose:
            return Color(red: 0.9, green: 0.8, blue: 0.8)
        case .sky:
            return Color(red: 0.65, green: 0.8, blue: 0.9)
        case .terracotta:
            return Color(red: 0.85, green: 0.6, blue: 0.5)
        case .lavender:
            return Color(red: 0.8, green: 0.75, blue: 0.9)
        case .stone:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .indigo:
            return Color(red: 0.5, green: 0.55, blue: 0.7)
        case .teal:
            return Color(red: 0.5, green: 0.7, blue: 0.7)
        case .maroon:
            return Color(red: 0.7, green: 0.5, blue: 0.5)
        case .olive:
            return Color(red: 0.6, green: 0.65, blue: 0.5)
        case .coral:
            return Color(red: 0.9, green: 0.65, blue: 0.6)
        }
    }
}
