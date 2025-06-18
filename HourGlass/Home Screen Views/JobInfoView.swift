import SwiftUI
import SwiftData
import Foundation

struct JobInfoView: View {
    
    private enum JobTab {
        case overview, entries, edit
    }
    
    @Bindable var job: Job
    
    @Query private var timeEntries: [TimeEntry]
    
    @State private var isShowingTimeLoggerSheet = false
    @State private var selectedTab: JobTab = .overview
    
    @State private var sortOption = SortOption.newestFirst
    @State private var filterOption = FilterOption.all
    
    @Environment(\.modelContext) private var modelContext
    
    init(job: Job) {
        self.job = job
        let jobID = job.persistentModelID
        self._timeEntries = Query(filter: #Predicate<TimeEntry> { $0.job?.persistentModelID == jobID },
                                  sort: \.startTime, order: .reverse)
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                JobInfoOverviewView(job: job, timeEntries: timeEntries, isShowingTimeLoggerSheet: $isShowingTimeLoggerSheet)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Overview")
                    }
                    .tag(JobTab.overview)
                
                TimeEntriesListView(
                    job: job,
                    isShowingTimeLoggerSheet: $isShowingTimeLoggerSheet,
                    sortOption: $sortOption,
                    filterOption: $filterOption
                )
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("All Entries")
                }
                .tag(JobTab.entries)
                
                JobEditView(job: job)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Edit Job")
                    }
                    .tag(JobTab.edit)
            }
            .navigationBarTitleDisplayMode(.inline)
            .tabBarMinimizeBehavior(.onScrollDown)
            .sheet(isPresented: $isShowingTimeLoggerSheet) {
                TimeLoggingView(job: job)
            }
            
        }
        .toolbar {
            if selectedTab == .entries {
                ToolbarItem {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Filter", selection: $filterOption) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Options", systemImage: "slider.horizontal.3")
                    }
                }
            }
            
            
            if selectedTab == .overview || selectedTab == .entries {
                ToolbarItem {
                    Button("Add", systemImage: "clock") {
                        isShowingTimeLoggerSheet = true
                    }
                }
            }
            
        }
        
    }
}

struct JobInfoOverviewView: View {
    
    var job: Job
    var timeEntries: [TimeEntry]
    @Binding var isShowingTimeLoggerSheet: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                JobInfoHeaderView(name: job.name, iconName: job.systemIconName)
                    .padding(.horizontal)
                
                JobInfoCardView(job: job)
                    .padding()
                
                VStack (alignment: .leading) {
                    if !timeEntries.isEmpty {
                        JobCalendarView(timeEntries: timeEntries)
                    } else {
                        VStack {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.largeTitle)
                                .padding(.bottom, 4)
                            Text("No Time Entries Yet")
                                .font(.headline)
                            Text("Tap the clock icon to add the first entry.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .glassEffect(in: .rect(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .background(Color(job.colorTheme.displayColor).opacity(colorScheme == .light ? 0.7 : 1.0))
    }
}

struct JobInfoCardView : View {
    
    var job: Job
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .font(.headline)
                .padding(.bottom, 5)
            
            LabeledContent {
                Text(job.hourlyRate.formatted(.currency(code: "GBP")))
            } label: {
                Label("Hourly Rate", systemImage: "sterlingsign.circle")
            }
            
            Divider()
            
            LabeledContent {
                Text(job.dateCreated.formatted(date: .long, time: .omitted))
            } label: {
                Label("Date Created", systemImage: "calendar")
            }
            
            Divider()
            
            LabeledContent {
                Text(job.formattedTotalLoggedTime)
            } label: {
                Label("Total Time", systemImage: "clock")
            }
            
            Divider()
            
            LabeledContent {
                Text((job.totalLoggedTime / 3600 * job.hourlyRate).formatted(.currency(code: "GBP")))
            } label: {
                Label("Total Earnings", systemImage: "banknote")
            }
            
        }
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }
}

struct JobInfoHeaderView: View {
    
    let name: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 48, weight: .light))
                    .padding(10)
                    .shadow(color: .black.opacity(0.15), radius: 15)
            }
            .frame(maxWidth: .infinity,
                   alignment: .center)
            
            Text(name)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let sampleJob = Job(name: "Sample Job",
                        dateCreated: .now, hourlyRate: 25.0,
                        colorTheme: JobColor.lavender)
    
    return NavigationStack {
        JobInfoView(job: sampleJob)
            .modelContainer(for: [Job.self, TimeEntry.self])
    }
}
