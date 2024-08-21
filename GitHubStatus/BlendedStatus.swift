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
    
    var type: String{
        switch self {
            
        case .allsystemsoperational:
            return "All Systems Operational"
        case .minorserviceoutage:
            return "Minor Service Outage"
        case .partialsystemoutage:
            return "Partial System Outage"
        case .majorserviceoutage:
            return "Major Service Outage"
        }
    }
}
