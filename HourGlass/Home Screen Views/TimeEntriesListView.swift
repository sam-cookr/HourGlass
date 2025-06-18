import SwiftUI
import SwiftData

struct TimeEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let job: Job
    
    @Binding var isShowingTimeLoggerSheet: Bool
    @Binding var sortOption: SortOption
    @Binding var filterOption: FilterOption
    
    var body: some View {
        VStack {
            FilteredTimeEntriesView(job: job, sortOption: sortOption, filterOption: filterOption)
        }
    }
}

private struct FilteredTimeEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeEntries: [TimeEntry]

    init(job: Job, sortOption: SortOption, filterOption: FilterOption) {
        let now = Date()
        let calendar = Calendar.current
        let jobID = job.id
        
        let startDate: Date? = {
            switch filterOption {
            case .pastWeek:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .pastMonth:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .all:
                return nil
            }
        }()

        let predicate: Predicate<TimeEntry> = {
            if let startDate = startDate {
                return #Predicate<TimeEntry> { entry in
                    entry.job?.id == jobID && entry.startTime >= startDate
                }
            } else {
                return #Predicate<TimeEntry> { entry in
                    entry.job?.id == jobID
                }
            }
        }()
        
        _timeEntries = Query(filter: predicate, sort: [sortOption.descriptor])
    }

    var body: some View {
        if timeEntries.isEmpty {
            ContentUnavailableView("No Time Entries Found", systemImage: "clock.badge.xmark")
        } else {
            List {
                ForEach(timeEntries) { entry in
                    TimeEntryRow(entry: entry)
                }
                .onDelete(perform: deleteItems)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(timeEntries[index])
            }
        }
    }
}

private struct TimeEntryRow: View {
    let entry: TimeEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .lineLimit(2)
                }
            }
            Spacer()
            Text(entry.formattedDuration)
                .font(.headline)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case longestFirst = "Longest First"
    case shortestFirst = "Shortest First"

    var id: Self { self }

    var descriptor: SortDescriptor<TimeEntry> {
        switch self {
        case .newestFirst:
            return SortDescriptor(\TimeEntry.startTime, order: .reverse)
        case .oldestFirst:
            return SortDescriptor(\TimeEntry.startTime, order: .forward)
        case .longestFirst:
            return SortDescriptor(\TimeEntry.duration, order: .reverse)
        case .shortestFirst:
            return SortDescriptor(\TimeEntry.duration, order: .forward)
        }
    }
}

enum FilterOption: String, CaseIterable, Identifiable {
    case all = "All Time"
    case pastWeek = "Past 7 Days"
    case pastMonth = "Past 30 Days"
    
    var id: Self { self }
}

extension TimeEntry {
    var formattedDuration: String {
        guard duration > 0 else { return "00:00" }
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimeEntry.self, Job.self, configurations: config)

    let job1 = Job(name: "Website Development", colorTheme: .sky)
    container.mainContext.insert(job1)

    let entry1 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 2), endTime: .now.addingTimeInterval(-3600), notes: "Worked on the homepage.", job: job1)
    container.mainContext.insert(entry1)

    return NavigationStack {
         TimeEntriesListView(
            job: job1,
            isShowingTimeLoggerSheet: .constant(false),
            sortOption: .constant(.newestFirst),
            filterOption: .constant(.all)
         )
         .modelContainer(container)
    }
}
