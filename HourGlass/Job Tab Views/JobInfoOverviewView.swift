import SwiftUI
import SwiftData
import ConfettiSwiftUI

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
        .animation(.spring(response: 0.6, dampingFraction: 1), value: job.isCompleted)
        .confettiCannon(trigger: $isConfettiCannonActive, num: 200)
        .onChange(of: job.isCompleted) { _, isCompleted in
            if isCompleted {
                isConfettiCannonActive = true
            }
        }
    }
}


