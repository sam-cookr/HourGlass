import SwiftUI
import SwiftData

struct TimeLoggingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let job: Job
    
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var notes: String = ""
    @State private var isBillable: Bool = true
    @State private var useCustomRate: Bool = false
    @State private var customRateString: String = ""

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
                
                Section(header: Text("Billing Details")) {
                    Toggle("Billable Entry", isOn: $isBillable)
                    Toggle("Set Custom Hourly Rate", isOn: $useCustomRate.animation())
                    
                    if useCustomRate {
                        HStack {
                            Text("Custom Rate")
                            TextField("Rate", text: $customRateString, prompt: Text(job.hourlyRate, format: .number))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
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
                    .disabled(endTime < startTime)
                }
            }
        }
    }

    private func logTime() {
        let calendar = Calendar.current
        
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let finalStartDate = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: selectedDate),
              var finalEndDate = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: selectedDate) else {
            return
        }

        if finalEndDate < finalStartDate {
            finalEndDate = calendar.date(byAdding: .day, value: 1, to: finalEndDate)!
        }
        
        let customRate = useCustomRate ? Double(customRateString) : nil

        let newTimeEntry = TimeEntry(
            startTime: finalStartDate,
            endTime: finalEndDate,
            notes: notes.isEmpty ? nil : notes,
            job: job,
            isBillable: isBillable,
            customRate: customRate
        )
        
        modelContext.insert(newTimeEntry)
    }
}
