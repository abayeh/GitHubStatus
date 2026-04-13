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

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.githubstatus.app",
        category: "network"
    )
    private var refreshTask: Task<Void, Never>?

    func startTimers() {
        stopTimers()
        refreshTask = Task { @MainActor in
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
        Task { @MainActor in
            await fetchAll()
        }
    }

    private func fetchAll() async {
        errorMessage = nil
        var hadAnyError = false
        var successfulComponents = false
        var successfulStatus = false

        // Run both fetches concurrently, catching errors into optionals
        async let componentsResult = safeFetchComponents()
        async let statusResult = safeFetchOverallStatus()

        // Await both results
        let fetchedComponents = await componentsResult
        let fetchedStatus = await statusResult

        // Process components result
        if let comps = fetchedComponents {
            self.components = comps
            successfulComponents = true
        } else {
            hadAnyError = true
            logger.error("Failed to fetch components")
        }

        // Process status result
        if let status = fetchedStatus {
            overallStatus = status
            successfulStatus = true
        } else {
            hadAnyError = true
            logger.error("Failed to fetch overall status")
        }

        // Only advance lastUpdated if at least one fetch succeeded
        if successfulComponents || successfulStatus {
            lastUpdated = Date()
        }

        // Show error if any fetch failed
        if hadAnyError {
            if !successfulComponents && !successfulStatus {
                errorMessage = "Failed to fetch GitHub status"
            } else if !successfulComponents {
                errorMessage = "Failed to fetch component details"
            } else if !successfulStatus {
                errorMessage = "Failed to fetch overall status"
            }
            // Don't update components if components fetch failed - keep old data
            if !successfulComponents && fetchedComponents == nil {
                // Components failed but status may have succeeded
                // Keep existing components to avoid showing empty list
            }
        }

        updateMenubarIcon()
    }

    private func safeFetchComponents() async -> [Component]? {
        do {
            return try await fetchComponentsAsync()
        } catch {
            logger.error("Failed to fetch components: \(error)")
            return nil
        }
    }

    private func safeFetchOverallStatus() async -> OverallStatus? {
        do {
            return try await fetchOverallStatusAsync()
        } catch {
            logger.error("Failed to fetch overall status: \(error)")
            return nil
        }
    }

    nonisolated private func fetchComponentsAsync() async throws -> [Component] {
        let url = URL(string: "https://www.githubstatus.com/api/v2/components.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        return decodedResponse.components
    }

    nonisolated private func fetchOverallStatusAsync() async throws -> OverallStatus {
        let url = URL(string: "https://www.githubstatus.com/api/v2/status.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decodedStatus = try JSONDecoder().decode(StatusAPIResponse.self, from: data)
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
