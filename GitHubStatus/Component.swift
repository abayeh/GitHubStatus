//
//  Component.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

struct Component: Codable {
    let id: String
    let name: String
    let status: ComponentStatus
    let description: String?
    let createdAt: String?   // Make this optional
    let updatedAt: String
    let position: Int
    let group: Bool
    let onlyShowIfDegraded: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case description
        case createdAt = "created_at"   // Map the JSON key to the Swift property
        case updatedAt = "updated_at"
        case position
        case group
        case onlyShowIfDegraded = "only_show_if_degraded"
    }
    
    static var placeholder: Component {
        Component(id: "0", name: "Placeholder", status: .operational, description: nil, createdAt: nil, updatedAt: "", position: 0, group: false, onlyShowIfDegraded: false)
    }
}
