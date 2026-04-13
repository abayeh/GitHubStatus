//
//  ComponentViewModel.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//
import SwiftUI
import Cocoa
import os

@MainActor
class ComponentViewModel: ObservableObject {
    @Published var components: [Component] = []
    @Published var overallStatus: OverallStatus = .placeholder
    @Published var lastUpdated: Date? = nil
    @Published var errorMessage: String? = nil

    private let logger = Logger(subsystem: "com.githubstatus.app", category: "network")
    private var refreshTask: Task<Void, Never>?

    func startTimers() {
        refreshTask = Task {
            while !Task.isCancelled {
                await fetchAll()
                try? await Task.sleep(nanoseconds: 120_000_000_000) // 120 seconds
            }
        }
    }

    func stopTimers() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func fetchComponents() {
        Task {
            await fetchAll()
        }
    }

    private func fetchAll() async {
        errorMessage = nil

        async let componentsResult: [Component] = fetchComponentsAsync()
        async let statusResult: OverallStatus = fetchOverallStatusAsync()

        let (fetchedComponents, fetchedStatus) = await (try? await componentsResult ?? [], try? await statusResult ?? .placeholder)

        if !fetchedComponents.isEmpty {
            components = fetchedComponents
        }
        overallStatus = fetchedStatus
        lastUpdated = Date()
        updateMenubarIcon()
    }

    private func fetchComponentsAsync() async throws -> [Component] {
        let url = URL(string: "https://www.githubstatus.com/api/v2/components.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            await MainActor.run { errorMessage = "Failed to fetch components" }
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        return decodedResponse.components
    }

    private func fetchOverallStatusAsync() async throws -> OverallStatus {
        let url = URL(string: "https://www.githubstatus.com/api/v2/status.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            await MainActor.run { errorMessage = "Failed to fetch overall status" }
            throw URLError(.badServerResponse)
        }

        let decodedStatus = try JSONDecoder().decode(OverallStatusResponse.self, from: data)
        return decodedStatus.status
    }

    private func updateMenubarIcon() {
        let buttonColor: Color
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

        let iconSwiftUI = ZStack(alignment: .center) {
            Text("GH")
                .font(.footnote)
                .background(
                    Circle()
                        .fill(buttonColor)
                        .frame(width: 18, height: 18)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.trailing, 5)
        }
        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 30, height: 18)

        guard let statusItem = AppDelegate.shared.statusItem else { return }
        statusItem.button?.subviews.forEach { $0.removeFromSuperview() }
        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
    }
}
