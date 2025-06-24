//
//  ExportJob.swift
//  HourGlass
//
//  Created by Sam Cook on 24/06/2025.
//

import Foundation

extension Job {
    func exportTimeEntriesToCSV() -> String {
        let header = "Start Time,End Time,Duration (HH:MM:ss),Notes,Is Billable,Rate,Earnings\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let rows = timeEntries?.map { entry -> String in
            let startTime = dateFormatter.string(from: entry.startTime)
            let endTime = entry.endTime.map { dateFormatter.string(from: $0) } ?? "N/A"
            
            let duration = formatDuration(timeInterval: entry.duration)
            let notes = sanitizeForCSV(entry.notes ?? "")
            let isBillable = entry.isBillable ? "Yes" : "No"
            let rate = String(format: "%.2f", entry.effectiveRate)
            let earnings = String(format: "%.2f", entry.earnings)

            return "\(startTime),\(endTime),\(duration),\(notes),\(isBillable),\(rate),\(earnings)"
        }.joined(separator: "\n") ?? ""

        return header + rows
    }

    private func formatDuration(timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func sanitizeForCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }
}
