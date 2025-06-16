//
//  TimeLoggingView.swift
//  OTC
//
//  Created by Sam Cook on 11/06/2025.
//


// TimeLoggingView.swift

import SwiftUI
import SwiftData

/// A view for logging a new time entry against a specific job.
struct TimeLoggingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let job: Job
    
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Date")) {
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }

                Section(header: Text("Log Time")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        logTime()
                        dismiss()
                    }
                    // Prevent saving if the end time is before the start time
                    .disabled(endTime < startTime)
                }
            }
        }
    }

    /// Creates and saves a new TimeEntry object based on the user's input.
    private func logTime() {
        let calendar = Calendar.current
        
        // Extract hour and minute from the time pickers
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // Combine the selected date with the start and end times
        guard let finalStartDate = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: selectedDate),
              var finalEndDate = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: selectedDate) else {
            return
        }

        // Adjust for entries that span across midnight
        if finalEndDate < finalStartDate {
            finalEndDate = calendar.date(byAdding: .day, value: 1, to: finalEndDate)!
        }

        // Create the new TimeEntry and insert it into the model context
        let newTimeEntry = TimeEntry(
            startTime: finalStartDate,
            endTime: finalEndDate,
            notes: notes.isEmpty ? nil : notes,
            job: job
        )
        
        modelContext.insert(newTimeEntry)
    }
}