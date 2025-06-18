import SwiftUI
import SwiftData

struct AddJobView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var jobDescription: String = ""
    @State private var hourlyRate: Double = 0.0

    @State private var colorTheme: JobColor = .slate
    @State private var systemIconName: String = "briefcase"
    


    var body: some View {
        NavigationStack {
            Form {
                Section("Job Details") {
                    TextField("Job Name", text: $name)
                    VStack(alignment: .leading) {
                        Text("Description").font(.caption).foregroundStyle(.secondary)
                        TextEditor(text: $jobDescription)
                        .frame(minHeight: 100)
                    }
                }
                
                Section("Hourly Rate (£)") {
                    TextField("Rate", value: $hourlyRate, format: .number)
                        .keyboardType(.decimalPad)
                    Stepper("Adjust Rate", value: $hourlyRate, in: 0...1000, step: 1.0)
                }

                Section("Theme") {
                    Picker("Color", selection: $colorTheme) {
                        ForEach(JobColor.allCases, id: \.self) { color in
                            Label {
                                Text(color.rawValue.capitalized)
                            } icon: {
                                Image(systemName: "square.fill")
                                    .foregroundStyle(color.displayColor)
                            }
                            .tag(color)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("Icon", selection: $systemIconName) {
                        ForEach(Job.iconOptions, id: \.self) { iconName in
                            Label(iconName.replacingOccurrences(of: ".", with: " ").capitalized, systemImage: iconName)
                                .tag(iconName)
                        }
                    }
                }
            }
            .navigationTitle("New Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addJob()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addJob() {
        let newJob = Job(
            name: name,
            jobDescription: jobDescription.isEmpty ? nil : jobDescription,
            hourlyRate: hourlyRate,
            colorTheme: colorTheme,
        )
        modelContext.insert(newJob)
    }
}

#Preview {
    AddJobView()
        .modelContainer(for: Job.self, inMemory: true)
}
