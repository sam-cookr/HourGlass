import SwiftUI
import SwiftData
import Foundation
import ConfettiSwiftUI

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
                    filterOption: $filterOption
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

struct JobCompletedView: View {
    @Bindable var job: Job
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .foregroundStyle(.white)
                .padding()
            
            Text("Job Completed")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                job.toggleCompleted()
            } label: {
                Label("Mark as Incomplete", systemImage: "arrow.uturn.backward.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white.opacity(0.2))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        
    }
}

struct JobInfoOverviewView: View {
    
    @Bindable var job: Job
    var timeEntries: [TimeEntry]
    @Binding var isShowingTimeLoggerSheet: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isConfettiCannonActive = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    JobInfoHeaderView(name: job.name, iconName: job.systemIconName)
                        .padding(.horizontal)
                    
                    if !job.isCompleted {
                        JobInfoCardView(job: job)
                            .padding()
                    }
                    
                    VStack(alignment: .leading) {
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
            .background(Color(job.colorTheme.displayColor)
                .opacity(colorScheme == .light ? 1 : 0.5))
            
            if job.isCompleted {
                JobCompletedView(job: job)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: job.isCompleted)
        .confettiCannon(
                    trigger: $isConfettiCannonActive,
                    num: 600,
                    confettiSize: 12.0,
                    fadesOut: true, radius: UIScreen.main.bounds.height
                )
        .onChange(of: job.isCompleted) { _, isCompleted in
            if isCompleted {
                isConfettiCannonActive = true
            }
        }
    }
}

struct JobInfoCardView : View {
    
    @Bindable var job: Job
    
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
            
            Divider()
            
            Button {
                job.toggleCompleted()
            } label: {
                Label("Mark as Complete", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .padding(.top)
        }
        .padding()
        .glassEffect(.regular, in : .rect(cornerRadius: 16))
        .transition(.scale.combined(with: .opacity))
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
                    .symbolColorRenderingMode(.gradient)
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
