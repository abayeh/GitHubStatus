//
//  BlendedStatus.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

enum BlendedStatus: String, Codable, CaseIterable {
    case allsystemsoperational = "All Systems Operational"
    case minorserviceoutage = "Minor Service Outage"
    case partialsystemoutage = "Partial System Outage"
    case majorserviceoutage = "Major Service Outage"
    case partiallydegradedservice = "Partially Degraded Service"

    // Fallback decoder: unknown values default to .allsystemsoperational
    // to prevent crashes from future API additions.
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = BlendedStatus(rawValue: rawValue) ?? .allsystemsoperational
    }
}