//
//  HourGlassApp.swift
//  HourGlass
//
//  Created by Sam Cook on 16/06/2025.
//

// HourGlassApp.swift

import SwiftUI
import SwiftData

@main
struct HourGlassApp: App {
    var sharedModelContainer: ModelContainer = {
        // Add Job.self to the schema
        let schema = Schema([
            Job.self

        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
