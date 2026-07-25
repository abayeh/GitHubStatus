//
//  IncidentImpact.swift
//  GitHubStatus
//

import Foundation

enum IncidentImpact: String, Codable {
    case none = "none"
    case minor = "minor"
    case major = "major"
    case critical = "critical"
    case maintenance = "maintenance"

    /// Severity ordering for sorting incidents by impact.
    var order: Int {
        switch self {
        case .none: return 0
        case .maintenance: return 1
        case .minor: return 2
        case .major: return 3
        case .critical: return 4
        }
    }

    /// Convert to the corresponding overall status indicator.
    var toOverallIndicator: OverallIndicator {
        switch self {
        case .none: return .none
        case .minor: return .minor
        case .major: return .major
        case .critical: return .critical
        case .maintenance: return .maintenance
        }
    }

    /// Human-readable label for display.
    var displayName: String {
        switch self {
        case .none: return "None"
        case .minor: return "Minor"
        case .major: return "Major"
        case .critical: return "Critical"
        case .maintenance: return "Maintenance"
        }
    }

    // Fallback decoder: unknown values default to .none
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = IncidentImpact(rawValue: rawValue) ?? .none
    }
}