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
    critical = "critical",
    maintenance = "maintenance"

    // Fallback decoder: unknown values default to .none
    // to prevent crashes from future API additions.
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = OverallIndicator(rawValue: rawValue) ?? .none
    }
}