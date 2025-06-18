//
//  Untitled.swift
//  HourGlass
//
//  Created by Sam Cook on 18/06/2025.
//

import SwiftUI
import SwiftData

struct JobCardView: View {
    var job: Job
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: job.systemIconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width:48, height: 48)
                .padding(4)
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                

            VStack(alignment: .leading) {
                Text(job.name)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(job.formattedTotalLoggedTime)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                
                Text((job.totalLoggedTime / 3600 * job.hourlyRate).formatted(.currency(code: "GBP")))
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
            }

            Spacer()

            if job.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
            }
        }
        .padding()
        .background(job.colorTheme.displayColor)
        .cornerRadius(12)
    }
}

#Preview {
    let sampleJob = Job(
        name: "Client Website Redesign",
        jobDescription: "Complete overhaul of the main client-facing website, including new branding.",
        hourlyRate: 75.0,
        isCompleted: false,
        colorTheme: .sky
    )
    
    JobCardView(job: sampleJob)
}
