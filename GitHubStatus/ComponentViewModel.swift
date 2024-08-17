//
//  ComponentViewModel.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//
import SwiftUI
import Combine
import Cocoa

class ComponentViewModel: ObservableObject {
    @Published var components: [Component] = []
    @Published var overallStatus: OverallStatus = .placeholder  // Store the overall status
    @Published var lastUpdated: Date? = nil
    

    func startTimers() {
        Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
            self.fetchComponents()
        }
    }

    // Method to fetch components
    func fetchComponents() {
        let url = URL(string: "https://www.githubstatus.com/api/v2/components.json")!

        // Print fetching the components and the full timestamp for debugging
        print("Fetching components at \(Date())")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.components = decodedResponse.components
                        self.lastUpdated = Date()
                        self.fetchOverallStatus()  // Fetch overall status after components are fetched
                    }
                } catch {
                    print("Error decoding components: \(error)")
                }
            } else if let error = error {
                print("Failed to fetch components:", error)
            }
        }.resume()
    }

    // Method to fetch the overall status
    func fetchOverallStatus() {
        let url = URL(string: "https://www.githubstatus.com/api/v2/status.json")!

        // Print fetching the status and the full timestamp for debugging
        print("Fetching status at \(Date())")   

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedStatus = try JSONDecoder().decode(OverallStatusResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.overallStatus = decodedStatus.status
                        self.updateMenubarIcon()
                    }
                } catch {
                    print("Error decoding status: \(error)")
                }
            } else if let error = error {
                print("Failed to fetch overall status:", error)
            }
        }.resume()
    }

    // Method to update the menubar icon based on the overall status
    private func updateMenubarIcon() {
        var buttonColor: Color
        
        switch overallStatus.indicator {
        case .none:
            buttonColor = Color.green
        case .minor:
            buttonColor = Color.yellow
        case .major:
            buttonColor = Color.orange
        case .critical:
            buttonColor = Color.red
        }
        
        let iconSwiftUI = ZStack(alignment:.center) {
            Text("GH")
                .font(.footnote)
                .background(
                    Circle()
                        .fill(buttonColor)
                        .frame(width: 18, height: 18)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .center)
                .padding(.trailing, 5)
        }
        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 30, height: 18)
        
        guard let statusItem = AppDelegate.shared.statusItem else {
            print("Failed to update menubar icon")
            return
        }
        statusItem.button?.subviews.forEach { $0.removeFromSuperview() }
        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame        
    }
}

// Struct to decode the overall status response from the API
struct OverallStatusResponse: Codable {
    let status: OverallStatus
}
