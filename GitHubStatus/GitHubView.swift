//
//  ContentView.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import SwiftUI

struct GitHubView: View {
    @EnvironmentObject var viewModel: ComponentViewModel
    @State private var refreshRotation: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(formattedDate(lastUpdated))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    viewModel.fetchComponents()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(refreshRotation))
                        .animation(.easeInOut(duration: 0.3), value: refreshRotation)
                }
                .buttonStyle(.plain)
                .onReceive(viewModel.$lastUpdated.dropFirst()) { _ in
                    withAnimation {
                        refreshRotation += 360
                    }
                }
                Spacer()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }

            // Active Incidents
            let activeIncidents = viewModel.incidents.filter { $0.isActive }
            if !activeIncidents.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Incidents")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)

                    ForEach(activeIncidents, id: \.id) { incident in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(incident.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            HStack(spacing: 4) {
                                Text(incident.impact.displayName)
                                    .font(.caption2)
                                    .foregroundColor(impactColor(incident.impact))
                                if let latestUpdate = incident.incidentUpdates.first {
                                    Text("·")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(latestUpdate.body.prefix(80))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.bottom, 4)
            }

            // Scheduled Maintenance
            let upcomingMaintenance = viewModel.scheduledMaintenances.filter { $0.isUpcomingOrActive }
            if !upcomingMaintenance.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scheduled Maintenance")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    ForEach(upcomingMaintenance, id: \.id) { maintenance in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(maintenance.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(maintenance.status == "in_progress"
                                 ? "In progress"
                                 : "Starts: \(formatMaintenanceDate(maintenance.scheduledFor))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.bottom, 4)
            }

            // Component Status List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.components.filter { $0.name != "Visit www.githubstatus.com for more information" }, id: \.id) { component in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(component.status.color)
                                .frame(width: 10, height: 10)

                            Text(component.name)
                                .font(.subheadline)

                            Spacer()

                            Text(component.status.type)
                                .font(.caption)
                                .foregroundColor(component.status.color)
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.footnote)
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(minWidth: 280, idealWidth: 300, maxWidth: 360,
               minHeight: 200, idealHeight: 400, maxHeight: 600)
        .onAppear {
            // Polling is managed by AppDelegate for continuous background updates
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatMaintenanceDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: isoString) else { return isoString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }

    private func impactColor(_ impact: IncidentImpact) -> Color {
        switch impact {
        case .none:
            return .secondary
        case .minor:
            return .yellow
        case .major:
            return .orange
        case .critical:
            return .red
        case .maintenance:
            return .blue
        }
    }
}

@MainActor
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubView()
            .environmentObject(ComponentViewModel())
    }
}
#Preview {
    GitHubView()
        .environmentObject(ComponentViewModel())
}