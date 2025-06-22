import SwiftUI
import SwiftData
import Foundation


struct JobInfoView: View {
    
    private enum JobTab {
        case overview, entries
    }
    
    @Bindable var job: Job
    
    @Query private var timeEntries: [TimeEntry]
    
    @State private var isShowingTimeLoggerSheet = false
    @State private var isShowingEditJobSheet = false
    @State private var selectedTab: JobTab = .overview
    
    @State private var sortOption = SortOption.newestFirst
    @State private var filterOption = FilterOption.all
    @State private var showBillableTag: Bool = true
    
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
                            .symbolEffect(.drawOn, isActive: selectedTab == .overview)
                        Text("Overview")
                    }
                    .tag(JobTab.overview)
                
                TimeEntriesListView(
                    job: job,
                    isShowingTimeLoggerSheet: $isShowingTimeLoggerSheet,
                    sortOption: $sortOption,
                    filterOption: $filterOption,
                    showBillableTag: $showBillableTag
                )
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                        .symbolEffect(.drawOn.individually, isActive: selectedTab == .entries)
                    Text("All Entries")
                }
                .tag(JobTab.entries)
            }
            .navigationBarTitleDisplayMode(.inline)
            .tabBarMinimizeBehavior(.onScrollDown)
            .sheet(isPresented: $isShowingTimeLoggerSheet) {
                TimeLoggingView(job: job)
            }
            .sheet(isPresented: $isShowingEditJobSheet) {
                JobEditView(job: job)
            }
            
        }
        .toolbar {
            
            if selectedTab == .entries {
                ToolbarItem {
                    Menu("Options", systemImage: "line.3.horizontal.decrease.circle") {
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
                        
                        Divider()
                        
                        Toggle(isOn: $showBillableTag) {
                            Text("Show Billable Tag")
                        }
                    }
                    
                }
            }
            
            if selectedTab == .overview {
                ToolbarItem {
                    Button("Edit", systemImage: "gear"){
                        isShowingEditJobSheet = true
                    }
                }
            }
            
            ToolbarSpacer(.fixed)
            
            ToolbarItem {
                Button("Add", systemImage: "clock") {
                    isShowingTimeLoggerSheet = true
                }
            }
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
