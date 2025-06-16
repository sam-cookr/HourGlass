//
//  Jo.swift
//  HourGlass
//
//  Created by Sam Cook on 16/06/2025.
//

import SwiftUI
import SwiftData
import Foundation

struct JobInfoView: View {
    
    @Bindable var job: Job
    
    // This query is now correctly filtered
    @Query private var timeEntries: [TimeEntry]
    
    @State private var isShowingTimeLoggerSheet = false
    
    // The initializer filters the query based on the specific job
    init(job: Job) {
        self.job = job
        let jobID = job.persistentModelID
        self._timeEntries = Query(filter: #Predicate<TimeEntry> { $0.job?.persistentModelID == jobID },
                                   sort: \.startTime, order: .reverse)
    }
    
    var body: some View {
        TabView {
            // Embed the overview view and apply the .tabItem modifier directly to it
            JobInfoOverviewView(job: job, isShowingTimeLoggerSheet: $isShowingTimeLoggerSheet)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Overview")
                }

            ContentView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

struct JobInfoOverviewView: View {
    
    var job: Job
    @Binding var isShowingTimeLoggerSheet: Bool
    
    // Declare environment variables in the view that uses them
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                JobInfoHeaderView(name: job.name, iconName: job.systemIconName)
                // You would presumably list your time entries here
                
                JobInfoCardView(job: job)
                    .padding()
                
                if !timeEntries.isEmpty {
                    JobCalendarView(timeEntries: timeEntries)
                }
            }
        }
        .background(Color(job.colorTheme.displayColor).opacity(colorScheme == .light ? 0.7 : 1.0))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "clock") {
                    isShowingTimeLoggerSheet = true
                }
                .buttonStyle(.glass)
            }
        }
        .sheet(isPresented: $isShowingTimeLoggerSheet) {
            // The sheet modifier is moved here to be controlled by the state
            TimeLoggingView(job: job)
        }
    }
}


struct JobInfoCardView : View {
    
    var job: Job
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .font(.headline)
                .padding(.bottom, 5)
            
            /// Hourly Rate
            LabeledContent {
                Text(job.hourlyRate.formatted(.currency(code: "GBP")))
            } label: {
                Label("Hourly Rate", systemImage: "sterlingsign.circle")
            }
            
            Divider()
            
            /// Date Created
            LabeledContent {
                Text(job.dateCreated.formatted(date: .long, time: .omitted))
            } label: {
                Label("Date Created", systemImage: "calendar")
            }
            
            Divider()
            
            /// Total time logged
            LabeledContent {
                Text(job.formattedTotalLoggedTime)
            } label: {
                Label("Total Time", systemImage: "clock")
            }
            
            Divider()
            
            /// Total Earnings
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
        .padding(.vertical)
    }
}


/// PREVIEW
#Preview {
    NavigationStack {
        let sampleJob = Job(
            name: "Design App Logo & Branding",
            jobDescription: "Create a modern and friendly logo for the new mobile application. The branding should reflect our core values of innovation and user-friendliness.",
            hourlyRate: 65.0,
            colorTheme: .sky
        )
        let sampleProject = Project(name: "Mobile App V2")
        sampleJob.parentProject = sampleProject
        
        let entry1 = TimeEntry(
            startTime: Date().addingTimeInterval(-18000),
            endTime: Date().addingTimeInterval(-14400),
            notes: "Initial brainstorming and concept sketches."
        )
        
        let entry2 = TimeEntry(
            startTime: Date().addingTimeInterval(-10800),
            endTime: Date().addingTimeInterval(-3600),
            notes: "Digital rendering of the selected logo design."
        )
        
        let entry3 = TimeEntry(
            startTime: Date().addingTimeInterval(-86400),
            endTime: Date().addingTimeInterval(-82800),
            notes: "Client meeting to discuss initial direction."
        )
        
        sampleJob.timeEntries?.append(contentsOf: [entry1, entry2, entry3])
        
        return JobInfoView(job: sampleJob)
    }
}

