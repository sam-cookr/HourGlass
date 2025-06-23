// JobCalendarView.swift
// HourGlass
//
// Created by Sam Cook on 16/06/2025.
//

import SwiftUI
// MARK: - Calendar View

struct JobCalendarView: View {
    let timeEntries: [TimeEntry]
    
    @State private var month: Date = .now

    private var dailyJobColors: [Date: Color] {
        var colors: [Date: Color] = [:]
        let calendar = Calendar.current

        for entry in timeEntries {
            let startOfDay = calendar.startOfDay(for: entry.startTime)
            if colors[startOfDay] == nil {
                colors[startOfDay] = entry.job?.colorTheme.displayColor ?? .gray
            }
        }
        return colors
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Activity Calendar")
                .font(.headline)
                .padding([.bottom, .horizontal], 5)

            VStack {
                headerView
                calendarGridView
            }
            .padding()
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 15))
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(month, formatter: monthYearFormatter)
                .font(.headline.bold())
            Spacer()
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.bottom, 8)
    }

    private var calendarGridView: some View {
        let days = monthDates()
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            ForEach(days, id: \.self) { date in
                if Calendar.current.isDate(date, equalTo: month, toGranularity: .month) {
                    DayCellView(date: date, entryColor: dailyJobColors[date])
                } else {
                    Color.clear
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yy"
        return formatter
    }
    
    private var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        
        return Array(symbols[firstWeekdayIndex...]) + Array(symbols[..<firstWeekdayIndex])
    }

    private func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: month) {
            month = newMonth
        }
    }

    private func monthDates() -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let firstDayOfGrid = calendar.date(byAdding: .day, value: -(weekdayOfFirstDay - calendar.firstWeekday), to: firstDayOfMonth)!

        var dates: [Date] = []
        for dayOffset in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfGrid) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        return dates
    }
}

// MARK: - Day Cell View

struct DayCellView: View {
    let date: Date
    let entryColor: Color?

    var body: some View {
        Text(dayFormatter.string(from: date))
            .font(.system(size: 14, weight: .medium))
            .padding(8)
            .frame(maxWidth: .infinity)
            .foregroundColor(foregroundColor)
            .background(backgroundCircle)
            .clipShape(Circle())
            .frame(height: 40)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    @ViewBuilder
    private var backgroundCircle: some View {
        if isToday {
            Circle().fill(Color.accentColor)
        } else if let entryColor {
            Circle().fill(entryColor)
        } else {
            Circle().fill(Color.clear)
        }
    }
    
    private var foregroundColor: Color {
        if isToday || entryColor != nil {
            return .white
        }
        return .primary
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}

// MARK: - Preview Provider

#Preview {
    let sampleJobs = [
        Job(name: "Website Redesign", colorTheme: JobColor.coral),
        
    ]
    
    let sampleEntries: [TimeEntry] = (0..<15).compactMap { index in
        guard !sampleJobs.isEmpty else { return nil }
        
        let randomDayOffset = Int.random(in: -20...20)
        guard let entryDate = Calendar.current.date(byAdding: .day, value: randomDayOffset, to: .now) else { return nil }
        
        let job = sampleJobs[index % sampleJobs.count]
        
        return TimeEntry(startTime: entryDate, job: job)
    }
    
    ScrollView {
        JobCalendarView(timeEntries: sampleEntries)
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
