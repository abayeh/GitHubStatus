//
//  OverallStatus.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

struct OverallStatus: Codable {
    let indicator: OverallIndicator
    let description: BlendedStatus
    
    static var placeholder: OverallStatus {
        OverallStatus(indicator: .none, description: .allsystemsoperational)
    }
}
