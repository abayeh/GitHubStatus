//
//  OverallIndicator.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

enum OverallIndicator: String, Codable, CaseIterable {
    case none = "none",
    minor = "minor",
    major = "major",
    critical = "cirtical"
    
    var type: String{
        switch self {
            
        case .none:
            return "none"
        case .minor:
            return "minor"
        case .major:
            return "major"
        case .critical:
            return "critical"
        }
    }
}
