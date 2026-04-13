//
//  BlendedStatus.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

enum BlendedStatus: String, Codable, CaseIterable {
    case allsystemsoperational = "All Systems Operational",
    minorserviceoutage = "Minor Service Outage",
    partialsystemoutage = "Partial System Outage",
    majorserviceoutage = "Major Service Outage"
}
