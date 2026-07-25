//
//  Incident.swift
//  GitHubStatus
//

import Foundation

struct Incident: Codable {
    let id: String
    let name: String
    let status: String
    let createdAt: String
    let updatedAt: String
    let monitoringAt: String?
    let resolvedAt: String?
    let impact: IncidentImpact
    let shortlink: String?
    let startedAt: String?
    let incidentUpdates: [IncidentUpdate]
    let components: [Component]

    enum CodingKeys: String, CodingKey {
        case id, name, status, impact, shortlink
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case monitoringAt = "monitoring_at"
        case resolvedAt = "resolved_at"
        case startedAt = "started_at"
        case incidentUpdates = "incident_updates"
        case components
    }

    /// Whether this incident is still active (not resolved or in postmortem)
    var isActive: Bool {
        switch status {
        case "resolved", "postmortem":
            return false
        default:
            return true
        }
    }
}

struct IncidentUpdate: Codable {
    let id: String
    let status: String
    let body: String
    let displayAt: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, status, body
        case displayAt = "display_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}