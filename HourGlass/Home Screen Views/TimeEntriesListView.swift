import SwiftUI
import SwiftData

struct TimeEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var sortOrder = SortOrder.descending
    @State private var filterOption = FilterOption.all
    
    var body: some View {
        NavigationStack {
            VStack {
                FilteredTimeEntriesView(sortOrder: sortOrder, filterOption: filterOption)
            }
            .navigationTitle("Time Entries")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort", selection: $sortOrder) {
                            Text("Newest First").tag(SortOrder.descending)
                            Text("Oldest First").tag(SortOrder.ascending)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $filterOption) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

private struct FilteredTimeEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeEntries: [TimeEntry]

    init(sortOrder: SortOrder, filterOption: FilterOption) {
        let now = Date()
        let calendar = Calendar.current
        
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

        let predicate: Predicate<TimeEntry>? = {
            if let startDate = startDate {
                return #Predicate<TimeEntry> { entry in
                    entry.startTime >= startDate
                }
            }
            return nil
        }()
        
        _timeEntries = Query(filter: predicate, sort: [SortDescriptor<TimeEntry>(\.startTime, order: sortOrder.descriptor)])
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
                Text(entry.job?.name ?? "No Job Assigned")
                    .font(.headline)
                Text(entry.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
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

private enum SortOrder {
    case ascending
    case descending

    var descriptor: Foundation.SortOrder {
        switch self {
        case .ascending: .forward
        case .descending: .reverse
        }
    }
}

private enum FilterOption: String, CaseIterable, Identifiable {
    case all = "All Entries"
    case pastWeek = "Past Week"
    case pastMonth = "Past Month"
    
    var id: Self { self }
}

extension TimeEntry {
    var formattedDuration: String {
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
    let job2 = Job(name: "App Design", colorTheme: .rose)
    container.mainContext.insert(job1)
    container.mainContext.insert(job2)

    let entry1 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 2), endTime: .now.addingTimeInterval(-3600), notes: "Worked on the homepage.", job: job1)
    let entry2 = TimeEntry(startTime: .now.addingTimeInterval(-86400 * 3), endTime: .now.addingTimeInterval(-86400 * 3 + 1800), notes: "Initial wireframes.", job: job2)
    let entry3 = TimeEntry(startTime: .now.addingTimeInterval(-86400 * 10), endTime: .now.addingTimeInterval(-86400 * 10 + 7200), notes: "API integration.", job: job1)
    
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    container.mainContext.insert(entry3)


    return TimeEntriesListView()
        .modelContainer(container)
}