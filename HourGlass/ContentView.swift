//
//  ContentView.swift
//  HourGlass
//
//  Created by Sam Cook on 16/06/2025.
//
import SwiftUI
import SwiftData

struct ContentView: View {

    @Query(sort: \Job.dateCreated, order: .reverse) private var jobs: [Job]

    var body: some View {
        JobScrollView(jobs: jobs)
    }
}

#Preview {

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Job.self, configurations: config)

    let sampleJobs: [Job] = [
        Job(name: "Website Redesign", hourlyRate: 75.0, colorTheme: .slate),
        Job(name: "Mobile App Development", hourlyRate: 90.0, colorTheme: .sage)
    ]
    
    sampleJobs.forEach { container.mainContext.insert($0) }
    
    return ContentView()
        .modelContainer(container)
}
