//
//  GitHubStatusTests.swift
//  GitHubStatusTests
//
//  Created by Fig Bot on 13 Apr 2026.
//

import XCTest
@testable import GitHubStatus

final class GitHubStatusTests: XCTestCase {

    // MARK: - OverallIndicator

    func testOverallIndicatorRawValues() {
        XCTAssertEqual(OverallIndicator.none.rawValue, "none")
        XCTAssertEqual(OverallIndicator.minor.rawValue, "minor")
        XCTAssertEqual(OverallIndicator.major.rawValue, "major")
        XCTAssertEqual(OverallIndicator.critical.rawValue, "critical")
    }

    func testOverallIndicatorAllCasesDecodable() {
        let values = ["none", "minor", "major", "critical"]
        for value in values {
            let data = Data("\"\(value)\"".utf8)
            XCTAssertNoThrows {
                let decoded = try JSONDecoder().decode(OverallIndicator.self, from: data)
                XCTAssertEqual(decoded.rawValue, value)
            }
        }
    }

    // MARK: - ComponentStatus

    func testComponentStatusRawValues() {
        XCTAssertEqual(ComponentStatus.operational.rawValue, "operational")
        XCTAssertEqual(ComponentStatus.degraded_performance.rawValue, "degraded_performance")
        XCTAssertEqual(ComponentStatus.partial_outage.rawValue, "partial_outage")
        XCTAssertEqual(ComponentStatus.major_outage.rawValue, "major_outage")
    }

    func testComponentStatusTypeDisplay() {
        XCTAssertEqual(ComponentStatus.operational.type, "Operational")
        XCTAssertEqual(ComponentStatus.degraded_performance.type, "Degraded Performance")
        XCTAssertEqual(ComponentStatus.partial_outage.type, "Partial Outage")
        XCTAssertEqual(ComponentStatus.major_outage.type, "Major Outage")
    }

    // MARK: - BlendedStatus

    func testBlendedStatusRawValues() {
        XCTAssertEqual(BlendedStatus.allsystemsoperational.rawValue, "All Systems Operational")
        XCTAssertEqual(BlendedStatus.minorserviceoutage.rawValue, "Minor Service Outage")
        XCTAssertEqual(BlendedStatus.partialsystemoutage.rawValue, "Partial System Outage")
        XCTAssertEqual(BlendedStatus.majorserviceoutage.rawValue, "Major Service Outage")
    }

    func testBlendedStatusAllCasesDecodable() {
        let jsonStrings = [
            "\"All Systems Operational\"",
            "\"Minor Service Outage\"",
            "\"Partial System Outage\"",
            "\"Major Service Outage\""
        ]
        for json in jsonStrings {
            let data = Data(json.utf8)
            XCTAssertNoThrows {
                let decoded = try JSONDecoder().decode(BlendedStatus.self, from: data)
                XCTAssertFalse(decoded.rawValue.isEmpty)
            }
        }
    }

    // MARK: - Component

    func testComponentPlaceholder() {
        let placeholder = Component.placeholder
        XCTAssertEqual(placeholder.id, "0")
        XCTAssertEqual(placeholder.name, "Placeholder")
        XCTAssertEqual(placeholder.status, .operational)
        XCTAssertEqual(placeholder.position, 0)
        XCTAssertFalse(placeholder.group)
        XCTAssertFalse(placeholder.onlyShowIfDegraded)
    }

    func testComponentDecodingWithNewFields() throws {
        let json = """
        {
            "id": "1",
            "name": "Git Operations",
            "status": "operational",
            "description": "Git operations",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z",
            "position": 1,
            "group": false,
            "only_show_if_degraded": false,
            "showcase": true,
            "start_date": "2024-01-01",
            "group_id": "grp1",
            "page_id": "pg1"
        }
        """.data(using: .utf8)!

        let component = try JSONDecoder().decode(Component.self, from: json)
        XCTAssertEqual(component.id, "1")
        XCTAssertEqual(component.name, "Git Operations")
        XCTAssertEqual(component.status, .operational)
        XCTAssertEqual(component.position, 1)
        XCTAssertEqual(component.showcase, true)
        XCTAssertEqual(component.startDate, "2024-01-01")
        XCTAssertEqual(component.groupId, "grp1")
        XCTAssertEqual(component.pageId, "pg1")
    }

    func testComponentDecodingWithoutNewFields() throws {
        let json = """
        {
            "id": "2",
            "name": "API Requests",
            "status": "degraded_performance",
            "description": null,
            "created_at": null,
            "updated_at": "2024-01-02T00:00:00Z",
            "position": 4,
            "group": true,
            "only_show_if_degraded": true
        }
        """.data(using: .utf8)!

        let component = try JSONDecoder().decode(Component.self, from: json)
        XCTAssertEqual(component.id, "2")
        XCTAssertEqual(component.status, .degraded_performance)
        XCTAssertNil(component.showcase)
        XCTAssertNil(component.startDate)
        XCTAssertNil(component.groupId)
        XCTAssertNil(component.pageId)
    }

    // MARK: - APIResponse

    func testAPIResponseDecoding() throws {
        let json = """
        {
            "page": {
                "id": "abc",
                "name": "GitHub",
                "url": "https://www.githubstatus.com",
                "time_zone": "UTC",
                "updated_at": "2024-01-01T00:00:00Z"
            },
            "components": [
                {
                    "id": "1",
                    "name": "Git Operations",
                    "status": "operational",
                    "description": null,
                    "created_at": null,
                    "updated_at": "2024-01-01T00:00:00Z",
                    "position": 1,
                    "group": false,
                    "only_show_if_degraded": false
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(APIResponse.self, from: json)
        XCTAssertEqual(response.page.name, "GitHub")
        XCTAssertEqual(response.components.count, 1)
        XCTAssertEqual(response.components[0].name, "Git Operations")
    }

    // MARK: - OverallStatus

    func testOverallStatusPlaceholder() {
        let placeholder = OverallStatus.placeholder
        XCTAssertEqual(placeholder.indicator, .none)
        XCTAssertEqual(placeholder.description, .allsystemsoperational)
    }
}
