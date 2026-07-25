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
        XCTAssertEqual(OverallIndicator.maintenance.rawValue, "maintenance")
    }

    func testOverallIndicatorAllCasesDecodable() {
        let values = ["none", "minor", "major", "critical", "maintenance"]
        for value in values {
            let data = Data("\"\(value)\"".utf8)
            XCTAssertNoThrow {
                let decoded = try JSONDecoder().decode(OverallIndicator.self, from: data)
                XCTAssertEqual(decoded.rawValue, value)
            }
        }
    }

    func testOverallIndicatorUnknownValueFallback() {
        let data = Data("\"unknown_indicator\"".utf8)
        XCTAssertNoThrow {
            let decoded = try JSONDecoder().decode(OverallIndicator.self, from: data)
            XCTAssertEqual(decoded, .none)
        }
    }

    // MARK: - ComponentStatus

    func testComponentStatusRawValues() {
        XCTAssertEqual(ComponentStatus.operational.rawValue, "operational")
        XCTAssertEqual(ComponentStatus.under_maintenance.rawValue, "under_maintenance")
        XCTAssertEqual(ComponentStatus.degraded_performance.rawValue, "degraded_performance")
        XCTAssertEqual(ComponentStatus.partial_outage.rawValue, "partial_outage")
        XCTAssertEqual(ComponentStatus.major_outage.rawValue, "major_outage")
    }

    func testComponentStatusTypeDisplay() {
        XCTAssertEqual(ComponentStatus.operational.type, "Operational")
        XCTAssertEqual(ComponentStatus.under_maintenance.type, "Under Maintenance")
        XCTAssertEqual(ComponentStatus.degraded_performance.type, "Degraded Performance")
        XCTAssertEqual(ComponentStatus.partial_outage.type, "Partial Outage")
        XCTAssertEqual(ComponentStatus.major_outage.type, "Major Outage")
    }

    func testComponentStatusUnknownValueFallback() {
        let data = Data("\"future_status\"".utf8)
        XCTAssertNoThrow {
            let decoded = try JSONDecoder().decode(ComponentStatus.self, from: data)
            XCTAssertEqual(decoded, .operational)
        }
    }

    // MARK: - BlendedStatus

    func testBlendedStatusRawValues() {
        XCTAssertEqual(BlendedStatus.allsystemsoperational.rawValue, "All Systems Operational")
        XCTAssertEqual(BlendedStatus.minorserviceoutage.rawValue, "Minor Service Outage")
        XCTAssertEqual(BlendedStatus.partialsystemoutage.rawValue, "Partial System Outage")
        XCTAssertEqual(BlendedStatus.majorserviceoutage.rawValue, "Major Service Outage")
        XCTAssertEqual(BlendedStatus.partiallydegradedservice.rawValue, "Partially Degraded Service")
    }

    func testBlendedStatusAllCasesDecodable() {
        let jsonStrings = [
            "\"All Systems Operational\"",
            "\"Minor Service Outage\"",
            "\"Partial System Outage\"",
            "\"Major Service Outage\"",
            "\"Partially Degraded Service\""
        ]
        for json in jsonStrings {
            let data = Data(json.utf8)
            XCTAssertNoThrow {
                let decoded = try JSONDecoder().decode(BlendedStatus.self, from: data)
                XCTAssertFalse(decoded.rawValue.isEmpty)
            }
        }
    }

    func testBlendedStatusUnknownValueFallback() {
        let data = Data("\"Some Unknown Status Description\"".utf8)
        XCTAssertNoThrow {
            let decoded = try JSONDecoder().decode(BlendedStatus.self, from: data)
            XCTAssertEqual(decoded, .allsystemsoperational)
        }
    }

    // MARK: - IncidentImpact

    func testIncidentImpactRawValues() {
        XCTAssertEqual(IncidentImpact.none.rawValue, "none")
        XCTAssertEqual(IncidentImpact.minor.rawValue, "minor")
        XCTAssertEqual(IncidentImpact.major.rawValue, "major")
        XCTAssertEqual(IncidentImpact.critical.rawValue, "critical")
        XCTAssertEqual(IncidentImpact.maintenance.rawValue, "maintenance")
    }

    func testIncidentImpactOrder() {
        XCTAssertLessThan(IncidentImpact.none.order, IncidentImpact.minor.order)
        XCTAssertLessThan(IncidentImpact.minor.order, IncidentImpact.major.order)
        XCTAssertLessThan(IncidentImpact.major.order, IncidentImpact.critical.order)
    }

    func testIncidentImpactToOverallIndicator() {
        XCTAssertEqual(IncidentImpact.none.toOverallIndicator, .none)
        XCTAssertEqual(IncidentImpact.minor.toOverallIndicator, .minor)
        XCTAssertEqual(IncidentImpact.major.toOverallIndicator, .major)
        XCTAssertEqual(IncidentImpact.critical.toOverallIndicator, .critical)
        XCTAssertEqual(IncidentImpact.maintenance.toOverallIndicator, .maintenance)
    }

    func testIncidentImpactUnknownValueFallback() {
        let data = Data("\"unknown_impact\"".utf8)
        XCTAssertNoThrow {
            let decoded = try JSONDecoder().decode(IncidentImpact.self, from: data)
            XCTAssertEqual(decoded, .none)
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

    func testComponentDecodingUnderMaintenance() throws {
        let json = """
        {
            "id": "3",
            "name": "Codespaces",
            "status": "under_maintenance",
            "description": "Orchestration and Compute for GitHub Codespaces",
            "created_at": "2021-08-11T16:02:09.505Z",
            "updated_at": "2024-01-02T00:00:00Z",
            "position": 11,
            "group": false,
            "only_show_if_degraded": false,
            "showcase": true,
            "start_date": "2021-08-11",
            "group_id": null,
            "page_id": "kctbh9vrtdwd"
        }
        """.data(using: .utf8)!

        let component = try JSONDecoder().decode(Component.self, from: json)
        XCTAssertEqual(component.status, .under_maintenance)
    }

    // MARK: - OverallStatus

    func testOverallStatusPlaceholder() {
        let placeholder = OverallStatus.placeholder
        XCTAssertEqual(placeholder.indicator, .none)
        XCTAssertEqual(placeholder.description, "All Systems Operational")
    }

    // MARK: - Incident

    func testIncidentDecoding() throws {
        let json = """
        {
            "id": "abc123",
            "name": "Test Incident",
            "status": "identified",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T01:00:00Z",
            "monitoring_at": null,
            "resolved_at": null,
            "impact": "major",
            "shortlink": "https://stspg.io/abc123",
            "started_at": "2024-01-01T00:00:00Z",
            "incident_updates": [],
            "components": []
        }
        """.data(using: .utf8)!

        let incident = try JSONDecoder().decode(Incident.self, from: json)
        XCTAssertEqual(incident.id, "abc123")
        XCTAssertEqual(incident.name, "Test Incident")
        XCTAssertEqual(incident.impact, .major)
        XCTAssertTrue(incident.isActive)
    }

    func testIncidentIsNotActiveWhenResolved() throws {
        let json = """
        {
            "id": "abc123",
            "name": "Resolved Incident",
            "status": "resolved",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T02:00:00Z",
            "monitoring_at": "2024-01-01T01:30:00Z",
            "resolved_at": "2024-01-01T02:00:00Z",
            "impact": "minor",
            "shortlink": null,
            "started_at": "2024-01-01T00:00:00Z",
            "incident_updates": [],
            "components": []
        }
        """.data(using: .utf8)!

        let incident = try JSONDecoder().decode(Incident.self, from: json)
        XCTAssertFalse(incident.isActive)
    }

    // MARK: - ScheduledMaintenance

    func testScheduledMaintenanceDecoding() throws {
        let json = """
        {
            "id": "maint123",
            "name": "Scheduled Maintenance",
            "status": "scheduled",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z",
            "monitoring_at": null,
            "resolved_at": null,
            "impact": "maintenance",
            "shortlink": null,
            "scheduled_for": "2024-02-01T00:00:00Z",
            "scheduled_until": "2024-02-01T04:00:00Z",
            "incident_updates": [],
            "components": []
        }
        """.data(using: .utf8)!

        let maintenance = try JSONDecoder().decode(ScheduledMaintenance.self, from: json)
        XCTAssertEqual(maintenance.id, "maint123")
        XCTAssertEqual(maintenance.status, "scheduled")
        XCTAssertEqual(maintenance.impact, .maintenance)
        XCTAssertTrue(maintenance.isUpcomingOrActive)
    }

    func testScheduledMaintenanceNotUpcomingWhenCompleted() throws {
        let json = """
        {
            "id": "maint456",
            "name": "Completed Maintenance",
            "status": "completed",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-02-01T04:00:00Z",
            "monitoring_at": null,
            "resolved_at": "2024-02-01T04:00:00Z",
            "impact": "maintenance",
            "shortlink": null,
            "scheduled_for": "2024-02-01T00:00:00Z",
            "scheduled_until": "2024-02-01T04:00:00Z",
            "incident_updates": [],
            "components": []
        }
        """.data(using: .utf8)!

        let maintenance = try JSONDecoder().decode(ScheduledMaintenance.self, from: json)
        XCTAssertFalse(maintenance.isUpcomingOrActive)
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

    // MARK: - SummaryAPIResponse

    func testSummaryAPIResponseDecoding() throws {
        let json = """
        {
            "page": {
                "id": "kctbh9vrtdwd",
                "name": "GitHub",
                "url": "https://www.githubstatus.com",
                "time_zone": "Etc/UTC",
                "updated_at": "2024-01-01T00:00:00Z"
            },
            "components": [
                {
                    "id": "8l4ygp009s5s",
                    "name": "Git Operations",
                    "status": "operational",
                    "description": "Performance of git clones, pulls, pushes",
                    "created_at": "2017-01-31T20:05:05.370Z",
                    "updated_at": "2024-01-01T00:00:00Z",
                    "position": 1,
                    "group": false,
                    "only_show_if_degraded": false,
                    "showcase": true,
                    "start_date": null,
                    "group_id": null,
                    "page_id": "kctbh9vrtdwd"
                }
            ],
            "incidents": [
                {
                    "id": "inc1",
                    "name": "Test Incident",
                    "status": "identified",
                    "created_at": "2024-01-01T00:00:00Z",
                    "updated_at": "2024-01-01T01:00:00Z",
                    "monitoring_at": null,
                    "resolved_at": null,
                    "impact": "minor",
                    "shortlink": null,
                    "started_at": "2024-01-01T00:00:00Z",
                    "incident_updates": [],
                    "components": []
                }
            ],
            "scheduled_maintenances": [
                {
                    "id": "maint1",
                    "name": "Scheduled Maintenance",
                    "status": "scheduled",
                    "created_at": "2024-01-01T00:00:00Z",
                    "updated_at": "2024-01-01T00:00:00Z",
                    "monitoring_at": null,
                    "resolved_at": null,
                    "impact": "maintenance",
                    "shortlink": null,
                    "scheduled_for": "2024-02-01T00:00:00Z",
                    "scheduled_until": "2024-02-01T04:00:00Z",
                    "incident_updates": [],
                    "components": []
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(SummaryAPIResponse.self, from: json)
        XCTAssertEqual(response.components.count, 1)
        XCTAssertEqual(response.incidents.count, 1)
        XCTAssertEqual(response.scheduledMaintenances.count, 1)
        XCTAssertEqual(response.incidents[0].name, "Test Incident")
        XCTAssertEqual(response.scheduledMaintenances[0].name, "Scheduled Maintenance")
    }
}