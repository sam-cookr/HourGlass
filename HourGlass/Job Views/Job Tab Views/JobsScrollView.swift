//
//  JobsScrollView.swift
//  HourGlass
//
//  Created by Sam Cook on 18/06/2025.
//

import SwiftUI
import SwiftData


struct JobScrollView: View {
    
    var jobs: [Job]?
    @State private var showingAddJobSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if let jobs = jobs, !jobs.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(jobs) { job in
                                    NavigationLink {
                                        JobInfoView(job:job)
                                    } label: {
                                        JobCardView(job: job)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            // Add padding to the whole list
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No Jobs Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Tap the + button to create your first job.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        // Center the empty state content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("All Jobs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddJobSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                .sheet(isPresented: $showingAddJobSheet) {
                    AddJobView()
                }
            }
        }
        

    }
}

#Preview ("2 Sample Jobs") {
    let sampleJobs = [
        Job(
            id: UUID(),
            name: "Freelance iOS App",
            jobDescription: "Develop a SwiftUI-based iOS app for a local client.",
            dateCreated: Date(),
            updatedAt: nil,
            hourlyRate: 30.0,
            isCompleted: false,
            colorTheme: .coral
        ),
        Job(
            id: UUID(),
            name: "Website Redesign",
            jobDescription: "Modernise and relaunch a charity's Wordpress website.",
            dateCreated: Date().addingTimeInterval(-86400),
            updatedAt: Date(),
            hourlyRate: 25.0,
            isCompleted: true,
            colorTheme: .mist
        )
    ]
    
    JobScrollView(jobs: sampleJobs)

}
