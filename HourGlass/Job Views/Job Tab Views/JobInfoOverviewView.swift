import SwiftUI
import SwiftData
import ConfettiSwiftUI
import UniformTypeIdentifiers

struct JobInfoOverviewView: View {
    
    @Bindable var job: Job
    var timeEntries: [TimeEntry]
    @Binding var isShowingTimeLoggerSheet: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isConfettiCannonActive = false
    
    @State private var isExporting: Bool = false
    @State private var document: CSVFile?
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    JobInfoHeaderView(name: job.name, iconName: job.systemIconName)
                        .padding(.horizontal)
                    
                    
                    if !(job.jobDescription == nil) {
                        Text(job.jobDescription!)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .glassEffect(in: .rect(cornerRadius: 16))
                            .padding()
                    }
                    
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
                    
                    Button {
                        let csvString = job.exportTimeEntriesToCSV()
                        document = CSVFile(initialText: csvString)
                        isExporting = true
                    } label: {
                        Label("Export Time Entries", systemImage: "square.and.arrow.up")
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
        .animation(.spring(response: 0.6, dampingFraction: 1), value: job.isCompleted)
        .confettiCannon(trigger: $isConfettiCannonActive, num: 200)
        .onChange(of: job.isCompleted) { _, isCompleted in
            if isCompleted {
                isConfettiCannonActive = true
            }
        }
        .fileExporter(
                    isPresented: $isExporting,
                    document: document,
                    contentType: .commaSeparatedText,
                    defaultFilename: "\(job.name)-TimeEntries.csv"
        ) { result in
            switch result {
            case .success(let url):
                print("Successfully saved to \(url)")
            case .failure(let error):
                print("Failed to save: \(error.localizedDescription)")
            }
        }
    }
}


