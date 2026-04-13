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
    critical = "critical"
}
