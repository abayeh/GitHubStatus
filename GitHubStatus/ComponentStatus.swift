//
//  ComponentStatus.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation
import SwiftUI

enum ComponentStatus: String, Codable, CaseIterable {
    case operational = "operational"
    case degraded_performance = "degraded_performance"
    case partial_outage = "partial_outage"
    case major_outage = "major_outage"
    
    var type: String {
        switch self {
        case .operational:
            return "Operational"
        case .degraded_performance:
            return "Degraded Performance"
        case .partial_outage:
            return "Partial Outage"
        case .major_outage:
            return "Major Outage"
        }
    }
    
    var color: Color {
        switch self {
        case .operational:
            return Color.green
        case .degraded_performance:
            return Color.orange
        case .partial_outage:
            return Color.yellow
        case .major_outage:
            return Color.red
        }
    }
}
