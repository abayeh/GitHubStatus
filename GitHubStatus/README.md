# GitHubStatus

A lightweight macOS menu bar app that displays real-time GitHub service status. Built with SwiftUI and the Atlassian Statuspage API.

![Platform](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

GitHubStatus sits in your menu bar and shows you the current operational status of all GitHub services at a glance:

- ✅ Green — All operational
- 🟡 Yellow — Minor issues
- 🟠 Orange — Major issues
- 🔴 Red — Critical outage
- 🔵 Blue — Under maintenance

Click the menu bar icon to see the full component breakdown, active incidents, and upcoming scheduled maintenance.

## Features

- **Live status** — Polls `https://www.githubstatus.com/api/v2/` every 2 minutes
- **All components** — Dynamically displays all GitHub service components (Git Operations, Webhooks, API Requests, Issues, Pull Requests, Actions, Packages, Pages, Copilot, Codespaces, Copilot AI Model Providers, etc.)
- **Active incidents** — Shows active incidents with impact level and latest update
- **Scheduled maintenance** — Displays upcoming and in-progress scheduled maintenance
- **Auto-refresh** — Menu bar icon updates automatically with no interaction needed
- **Dynamic UI** — SwiftUI popover with scrollable component list
- **Error handling** — Shows a message if the API is unreachable
- **Low memory** — No background processes, single menu bar item
- **Resilient decoding** — Unknown API status values fall back to safe defaults instead of crashing

## API

Uses the free, public Atlassian Statuspage API (no auth required):

| Endpoint | Purpose |
|----------|---------|
| `GET https://www.githubstatus.com/api/v2/summary.json` | Component statuses, active incidents, and scheduled maintenance |

The app uses the `summary.json` endpoint which provides all data in a single request.

## Building

### Requirements

- macOS 14.5+ (deployment target)
- Xcode 15.4+ (or VS Code with the Swift extension)
- Swift 5.9+

### Xcode

```bash
# Clone the repo
git clone https://github.com/abayeh/GitHubStatus.git
cd GitHubStatus

# Open in Xcode
open GitHubStatus.xcodeproj
# Then Cmd+R to build and run
```

### VS Code

Install the [Swift extension](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang) from the VS Code marketplace, then:

```bash
# Clone the repo
git clone https://github.com/abayeh/GitHubStatus.git
cd GitHubStatus

# Set Xcode command line tools (first time only)
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Build
xcodebuild -project GitHubStatus.xcodeproj -scheme GitHubStatus -configuration Debug build

# Run tests
xcodebuild test -project GitHubStatus.xcodeproj -scheme GitHubStatus -configuration Debug

# Run the app
open build/Debug/GitHubStatus.app
```

> **Note:** If `xcodebuild` gives an error about requiring Xcode, run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` first.

### Command Line (Xcode)

```bash
xcodebuild -project GitHubStatus.xcodeproj -target GitHubStatus -configuration Debug build
xcodebuild test -project GitHubStatus.xcodeproj -scheme GitHubStatus -configuration Debug
```

The built app will be in `build/Debug/GitHubStatus.app`.

## Architecture

```
GitHubStatus/
├── GitHubStatusApp.swift           # App entry point + AppDelegate (menu bar setup)
├── GitHubView.swift                # SwiftUI popover view (components, incidents, maintenance)
├── ComponentViewModel.swift        # @MainActor ObservableObject, async/await networking
├── Component.swift                 # Codable data model for components
├── ComponentStatus.swift           # Status enum with color + display helpers
├── OverallStatus.swift             # Overall status model (indicator + description)
├── OverallIndicator.swift          # Status indicator enum (none/minor/major/critical/maintenance)
├── BlendedStatus.swift             # Human-readable status enum
├── Incident.swift                  # Codable model for active incidents + updates
├── IncidentImpact.swift            # Impact enum (none/minor/major/critical/maintenance)
├── ScheduledMaintenance.swift      # Codable model for scheduled maintenance
├── APIReponse.swift                # API response wrappers (APIResponse, SummaryAPIResponse, PageInfo)
└── Resources/
    └── Assets.xcassets             # App icon (GH initials)
```

### Key Design Decisions

- **Swift Concurrency** — Uses `async/await` and `@MainActor` instead of Combine callbacks
- **Menu Bar only** — No dock icon (`LSUIElement = true`), single status item
- **Single API call** — Uses `summary.json` to get components, incidents, and maintenance in one request
- **Graceful degradation** — Custom `init(from:)` decoders fall back to safe defaults for unknown enum values
- **New API fields** — `showcase`, `start_date`, `group_id`, `page_id` are decoded as optionals to handle future API changes

## Running Tests

```bash
xcodebuild test -project GitHubStatus.xcodeproj -target GitHubStatusTests -configuration Debug
```

## License

MIT — see LICENSE file.