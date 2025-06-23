import SwiftUI
import SwiftData

struct JobEditView: View {
    @Bindable var job: Job
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    
    private func deleteJob() {
        modelContext.delete(job)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section("Job Details") {
                        TextField("Job Name", text: $job.name)
                        VStack(alignment: .leading) {
                            Text("Description").font(.caption).foregroundStyle(.secondary)
                            TextEditor(text: Binding(
                                get: { job.jobDescription ?? "" },
                                set: { job.jobDescription = $0 }
                            ))
                            .frame(minHeight: 100)
                        }
                    }
                    
                    Section("Hourly Rate (£)") {
                        TextField("Rate", value: $job.hourlyRate, format: .number)
                            .keyboardType(.decimalPad)
                        Stepper("Adjust Rate", value: $job.hourlyRate, in: 0...1000, step: 1.0)
                    }

                    Section("Theme") {
                        Text("Color").font(.caption).foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(JobColor.allCases, id: \.self) { color in
                                    Button(action: {
                                        job.colorTheme = color
                                    }) {
                                        Circle()
                                            .fill(color.displayColor)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(job.colorTheme == color ? .blue : .clear, lineWidth: 3)
                                            )
                                            .padding(2)
                                    }
                                }
                            }
                        }
                        
                        Text("Icon").font(.caption).foregroundStyle(.secondary).padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Job.iconOptions, id: \.self) { iconName in
                                    Button(action: {
                                        job.systemIconName = iconName
                                    }) {
                                        Image(systemName: iconName)
                                            .font(.title2)
                                            .frame(width: 50, height: 50)
                                            .background(job.systemIconName == iconName ? .blue.opacity(0.2) : .gray.opacity(0.1))
                                            .foregroundStyle(job.systemIconName == iconName ? .blue : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
                    Section("Other Options") {
                        Button(action: deleteJob) {
                            Text("Delete Job")
                                .foregroundColor(.red)
                        }
                        
                    }
                }
            }
            .navigationTitle("Edit Job")
            .background(Color(job.colorTheme.displayColor).opacity(colorScheme == .light ? 0.7 : 1.0))
        }
    }
}

#Preview {
    let sampleJob = Job(name: "Sample Job",
                        dateCreated: .now, hourlyRate: 25.0,
                        colorTheme: JobColor.lavender)
    
    NavigationStack {
        JobEditView(job: sampleJob)
            .modelContainer(for: [Job.self, TimeEntry.self])
    }
}
