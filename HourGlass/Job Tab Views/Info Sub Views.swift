//
//  JobInfoCardView.swift
//  HourGlass
//
//  Created by Sam Cook on 21/06/2025.
//

import SwiftUI
import SwiftData

struct JobInfoCardView : View {
    
    @Bindable var job: Job
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .font(.headline)
                .padding(.bottom, 5)
            
            LabeledContent {
                Text(job.hourlyRate.formatted(.currency(code: "GBP")))
            } label: {
                Label("Hourly Rate", systemImage: "sterlingsign.circle")
            }
            
            Divider()
            
            LabeledContent {
                Text(job.dateCreated.formatted(date: .long, time: .omitted))
            } label: {
                Label("Date Created", systemImage: "calendar")
            }
            
            Divider()
            
            LabeledContent {
                Text(job.formattedTotalLoggedTime)
            } label: {
                Label("Total Time", systemImage: "clock")
            }
            
            Divider()
            
            LabeledContent {
                Text((job.totalLoggedTime / 3600 * job.hourlyRate).formatted(.currency(code: "GBP")))
            } label: {
                Label("Total Earnings", systemImage: "banknote")
            }
            
            Divider()
            
            Button {
                job.toggleCompleted()
            } label: {
                Label("Mark as Complete", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .padding(.top)
        }
        .padding()
        .glassEffect(.regular, in : .rect(cornerRadius: 16))
        .transition(.scale.combined(with: .opacity))
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
                    .symbolColorRenderingMode(.gradient)
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
    }
}

struct JobCompletedView: View {
    @Bindable var job: Job
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .frame(width: 200.0, height: 200.0)
                .font(.system(size: 125))
                //.foregroundStyle(Color.white.opacity(0.7))
                .glassEffect(.regular.interactive())
                .padding()
            
            Text("Job Completed")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                job.toggleCompleted()
            } label: {
                Label("Mark as Incomplete", systemImage: "arrow.uturn.backward.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white.opacity(0.2))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        
    }
}
