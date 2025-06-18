import SwiftUI
import SwiftData

struct TimeEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    let job: Job
    
    @Binding var isShowingTimeLoggerSheet: Bool
    @Binding var sortOption: SortOption
    @Binding var filterOption: FilterOption
    
    var body: some View {
        FilteredTimeEntriesView(job: job, sortOption: sortOption, filterOption: filterOption)
            .background(Color(job.colorTheme.displayColor).opacity(colorScheme == .light ? 0.7 : 1.0))
    }
}

private struct FilteredTimeEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeEntries: [TimeEntry]
    
    private let sortOption: SortOption
    
    init(job: Job, sortOption: SortOption, filterOption: FilterOption) {
        self.sortOption = sortOption
        
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
        
        let querySortDescriptor: SortDescriptor<TimeEntry>
        switch sortOption {
        case .newestFirst, .oldestFirst:
            querySortDescriptor = sortOption.descriptor
        case .longestFirst, .shortestFirst:
            querySortDescriptor = SortDescriptor(\TimeEntry.startTime, order: .reverse)
        }
        
        _timeEntries = Query(filter: predicate, sort: [querySortDescriptor])
    }
    
    private var sortedTimeEntries: [TimeEntry] {
        switch sortOption {
        case .newestFirst, .oldestFirst:
            return timeEntries
        case .longestFirst:
            return timeEntries.sorted { $0.duration > $1.duration }
        case .shortestFirst:
            return timeEntries.sorted { $0.duration < $1.duration }
        }
    }

    var body: some View {
        if sortedTimeEntries.isEmpty {
            ContentUnavailableView("No Time Entries Found", systemImage: "clock.badge.xmark")
                
        } else {
            List {
                ForEach(sortedTimeEntries) { entry in
                    TimeEntryRow(entry: entry)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .onDelete(perform: deleteItems)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let entriesToDelete = offsets.map { sortedTimeEntries[$0] }
            for entry in entriesToDelete {
                modelContext.delete(entry)
            }
        }
    }
}

private struct TimeEntryRow: View {
    let entry: TimeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text(entry.startTime, format: .dateTime.hour().minute())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "play.circle")
                    }
                    
                    Label {
                        if let endTime = entry.endTime {
                            Text(endTime, format: .dateTime.hour().minute())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } else {
                            Text("In Progress")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "stop.circle")
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(entry.formattedDuration)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text(entry.startTime, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let notes = entry.notes, !notes.isEmpty {
                Divider()
                Text(notes)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .backgroundStyle(.background.secondary)
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
        guard duration > 0 else { return "0m" }
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        var components: [String] = []
        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 || hours == 0 {
            components.append("\(minutes)m")
        }
        return components.joined(separator: " ")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimeEntry.self, Job.self, configurations: config)

    let job1 = Job(name: "Website Development", colorTheme: .sky)
    container.mainContext.insert(job1)

    let entry1 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 2), endTime: .now.addingTimeInterval(-3600), notes: "Worked on the homepage, focusing on the new responsive layout and fixing navigation bugs.", job: job1)
    let entry2 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 26), endTime: .now.addingTimeInterval(-3600 * 24), notes: "Set up the initial project structure and dependencies.", job: job1)
    let entry3 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 52), endTime: nil, notes: "This is an ongoing task that has not been completed yet.", job: job1)
    
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    container.mainContext.insert(entry3)


    return NavigationStack {
         TimeEntriesListView(
            job: job1,
            isShowingTimeLoggerSheet: .constant(false),
            sortOption: .constant(.newestFirst),
            filterOption: .constant(.all)
         )
         .navigationTitle(job1.name)
         .modelContainer(container)
    }
}
