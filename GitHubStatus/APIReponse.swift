//
//  APIReponse.swift
//  GitHubStatus
//
//  Created by Alexander Bayeh on 8/15/24.
//

import Foundation

struct APIResponse: Codable {
    let page: PageInfo
    let components: [Component]
}

struct PageInfo: Codable {
    let id: String
    let name: String
    let url: String
    let timeZone: String
    let updatedAt: String

    // Map JSON keys to Swift properties if needed
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case timeZone = "time_zone"
        case updatedAt = "updated_at"
    }
}
