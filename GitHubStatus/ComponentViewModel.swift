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
    @Published var incidents: [Incident] = []
    @Published var scheduledMaintenances: [ScheduledMaintenance] = []
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

        do {
            let summary = try await fetchSummary()
            self.components = summary.components
            self.incidents = summary.incidents
            self.scheduledMaintenances = summary.scheduledMaintenances

            // Derive overall status from active incidents and maintenance
            let activeIncidents = summary.incidents.filter { $0.isActive }
            let activeMaintenance = summary.scheduledMaintenances.filter { $0.isUpcomingOrActive }

            if let worstIncident = activeIncidents.sorted(by: { $0.impact.order > $1.impact.order }).first {
                self.overallStatus = OverallStatus(
                    indicator: worstIncident.impact.toOverallIndicator,
                    description: blendedStatusDescription(for: worstIncident.impact)
                )
            } else if activeMaintenance.contains(where: { $0.status == "in_progress" }) {
                self.overallStatus = OverallStatus(
                    indicator: .maintenance,
                    description: "Partially Degraded Service"
                )
            } else {
                self.overallStatus = OverallStatus(indicator: .none, description: "All Systems Operational")
            }

            lastUpdated = Date()
            updateMenubarIcon()
        } catch {
            errorMessage = "Failed to fetch GitHub status"
            logger.error("Failed to fetch summary: \(error)")
        }
    }

    nonisolated private func fetchSummary() async throws -> SummaryAPIResponse {
        let url = URL(string: "https://www.githubstatus.com/api/v2/summary.json")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(SummaryAPIResponse.self, from: data)
    }

    private func blendedStatusDescription(for impact: IncidentImpact) -> String {
        switch impact {
        case .none:
            return "All Systems Operational"
        case .minor:
            return "Minor Service Outage"
        case .major:
            return "Partial System Outage"
        case .critical:
            return "Major Service Outage"
        case .maintenance:
            return "Partially Degraded Service"
        }
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
        case .maintenance:
            buttonColor = Color.blue
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