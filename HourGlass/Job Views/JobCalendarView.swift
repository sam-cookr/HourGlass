import SwiftUI

// Renamed and modified to accept time entries directly
struct JobCalendarView: View {
    // It no longer has its own @Query.
    // It receives the specific time entries it needs to display.
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
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
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
                    let jobColor = dailyJobColors[date]
                    DayCellView(date: date, dotColor: jobColor)
                } else {
                    Color.clear
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // Just the month name is cleaner here
        return formatter
    }
    
    private var weekdaySymbols: [String] {
        Calendar.current.shortWeekdaySymbols
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

// DayCellView remains the same.
struct DayCellView: View {
    let date: Date
    let dotColor: Color?

    var body: some View {
        VStack(spacing: 4) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .foregroundColor(isToday ? .white : .primary)
                .background(
                    Circle()
                        .fill(isToday ? Color.accentColor : Color.clear)
                        .frame(width: 30, height: 30)
                )

            if let color = dotColor {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 40)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}