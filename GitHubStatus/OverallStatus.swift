//
//  OverallStatus.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

struct OverallStatus {
    let indicator: OverallIndicator
    let description: String

    static var placeholder: OverallStatus {
        OverallStatus(indicator: .none, description: "All Systems Operational")
    }
}