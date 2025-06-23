import SwiftUI
import SwiftData

struct TimeEntriesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    let job: Job
    
    @Binding var isShowingTimeLoggerSheet: Bool
    @Binding var sortOption: SortOption
    @Binding var filterOption: FilterOption
    @Binding var showBillableTag: Bool
    
    var body: some View {
        FilteredTimeEntriesView(job: job, sortOption: sortOption, filterOption: filterOption, showBillableTag: $showBillableTag)
            .background(Color(job.colorTheme.displayColor)
                .opacity(colorScheme == .light ? 1 : 0.5))
    }
}

private struct FilteredTimeEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeEntries: [TimeEntry]
    
    @Binding private var showBillableTag: Bool
    private let sortOption: SortOption
    
    init(job: Job, sortOption: SortOption, filterOption: FilterOption, showBillableTag: Binding<Bool>) {
        self.sortOption = sortOption
        self._showBillableTag = showBillableTag
        
        let now = Date()
        let calendar = Calendar.current
        let jobID = job.id
        
        let finalPredicate: Predicate<TimeEntry>

        switch filterOption {
        case .all:
            finalPredicate = #Predicate<TimeEntry> { $0.job?.id == jobID }
        case .pastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            finalPredicate = #Predicate<TimeEntry> { $0.job?.id == jobID && $0.startTime >= startDate }
        case .pastMonth:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            finalPredicate = #Predicate<TimeEntry> { $0.job?.id == jobID && $0.startTime >= startDate }
        case .billable:
            finalPredicate = #Predicate<TimeEntry> { $0.job?.id == jobID && $0.isBillable }
        case .nonBillable:
            finalPredicate = #Predicate<TimeEntry> { $0.job?.id == jobID && !$0.isBillable }
        }
        
        let querySortDescriptor: SortDescriptor<TimeEntry>
        switch sortOption {
        case .newestFirst, .oldestFirst:
            querySortDescriptor = sortOption.descriptor
        case .longestFirst, .shortestFirst:
            querySortDescriptor = SortDescriptor(\TimeEntry.startTime, order: .reverse)
        }
        
        _timeEntries = Query(filter: finalPredicate, sort: [querySortDescriptor])
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
                    TimeEntryRow(entry: entry, showBillableTag: $showBillableTag)
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
    @Binding var showBillableTag: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            HStack(alignment: .center) {
                if showBillableTag {
                    if entry.isBillable {
                        Text("Billable")
                            .font(.caption2).fontWeight(.medium)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    } else {
                        Text("Non-Billable")
                            .font(.caption2).fontWeight(.medium)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
                
                if entry.customRate != nil {
                    Text("Custom Rate")
                        .font(.caption2).fontWeight(.medium)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                if entry.isBillable {
                    Text(entry.earnings, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 16)
            
            if let notes = entry.notes, !notes.isEmpty {
                Divider().padding(.vertical, 4)
                Text(notes)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .glassEffect(.regular.interactive())
        //.backgroundStyle(.background.secondary)
        
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
    case billable = "Billable"
    case nonBillable = "Non-Billable"
    
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

    let job1 = Job(name: "Website Development", hourlyRate: 40.0, colorTheme: .sky)
    container.mainContext.insert(job1)

    let entry1 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 2), endTime: .now.addingTimeInterval(-3600), notes: "Worked on the homepage, focusing on the new responsive layout and fixing navigation bugs.", job: job1, isBillable: true)
    let entry2 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 26), endTime: .now.addingTimeInterval(-3600 * 24), notes: "Set up the initial project structure and dependencies.", job: job1, isBillable: true, customRate: 50.0)
    let entry3 = TimeEntry(startTime: .now.addingTimeInterval(-3600 * 52), endTime: .now.addingTimeInterval(-3600 * 51), notes: "Internal project meeting and planning.", job: job1, isBillable: false)
    
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    container.mainContext.insert(entry3)


    return NavigationStack {
         TimeEntriesListView(
            job: job1,
            isShowingTimeLoggerSheet: .constant(false),
            sortOption: .constant(.newestFirst),
            filterOption: .constant(.all),
            showBillableTag: .constant(true)
         )
         .navigationTitle(job1.name)
         .modelContainer(container)
    }
}
