//
//  ScheduledMaintenance.swift
//  GitHubStatus
//

import Foundation

struct ScheduledMaintenance: Codable {
    let id: String
    let name: String
    let status: String
    let createdAt: String
    let updatedAt: String
    let monitoringAt: String?
    let resolvedAt: String?
    let impact: IncidentImpact
    let shortlink: String?
    let scheduledFor: String
    let scheduledUntil: String
    let incidentUpdates: [IncidentUpdate]
    let components: [Component]

    enum CodingKeys: String, CodingKey {
        case id, name, status, impact, shortlink
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case monitoringAt = "monitoring_at"
        case resolvedAt = "resolved_at"
        case scheduledFor = "scheduled_for"
        case scheduledUntil = "scheduled_until"
        case incidentUpdates = "incident_updates"
        case components
    }

    /// Whether this maintenance is still upcoming or in progress.
    var isUpcomingOrActive: Bool {
        switch status {
        case "completed", "verifying":
            return false
        default:
            return true
        }
    }
}