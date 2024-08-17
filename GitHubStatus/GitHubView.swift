//
//  ContentView.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import SwiftUI

struct GitHubView: View {
    @StateObject private var viewModel = ComponentViewModel()
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(alignment: .leading) {
            // Button to manually fetch components
            HStack {
                Spacer() // Pushes everything to the center
                Button(action: {
                    viewModel.fetchComponents()
                }) {
                    Text("Fetch Status")
                }
                Spacer()
            }

            HStack {
                Spacer() // Pushes everything to the center
                // Display last updated time
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(formattedDate(lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                Spacer()
            }
            
            // Iterate over the components and display each status
            ForEach(viewModel.components.filter { $0.name != "Visit www.githubstatus.com for more information" }, id: \.id) { component in
                HStack {
                    Circle()
                        .fill(component.status.color)
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading) {
                        Text(component.name)
                            .font(.headline)
                        
                        Text(component.status.type)
                            .font(.subheadline)
                            .foregroundColor(component.status.color)
                    }
                }
                .padding(.vertical, 2)
            }
            Spacer()
            HStack {
                Spacer() // Pushes everything to the center
                Button("Close Program") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer() // Ensures the button stays centered
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchComponents() // Fetch the components when the view appears
            viewModel.startTimers()     // Start the timers
            // startAutoFetch()            // Start the automatic fetch timer
        }
        // .onDisappear {
        //     stopAutoFetch()             // Stop the timer when the view disappears
        // }
    }
    
    // // Function to start the timer
    // private func startAutoFetch() {
    //     timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
    //         viewModel.fetchComponents()
    //     }
    // }
    
    // // Function to stop the timer
    // private func stopAutoFetch() {
    //     timer?.invalidate()
    //     timer = nil
    // }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubView()
    }
}
#Preview {
    GitHubView()
        .frame(width: 200, height: 530)
}

