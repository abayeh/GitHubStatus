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

Click the menu bar icon to see the full component breakdown.

## Features

- **Live status** — Polls `https://www.githubstatus.com/api/v2/` every 2 minutes
- **All components** — Git Operations, Webhooks, API Requests, Issues, Pull Requests, Actions, Packages, Pages, Codespaces, Copilot
- **Auto-refresh** — Menu bar icon updates automatically with no interaction needed
- **Dynamic UI** — SwiftUI popover with scrollable component list
- **Error handling** — Shows a message if the API is unreachable
- **Low memory** — No background processes, single menu bar item

## API

Uses the free, public Atlassian Statuspage API (no auth required):

| Endpoint | Purpose |
|----------|---------|
| `GET https://www.githubstatus.com/api/v2/components.json` | Component statuses |
| `GET https://www.githubstatus.com/api/v2/status.json` | Overall status |

## Building

### Requirements

- macOS 12.0+
- Xcode 15.0+
- Swift 5.9+

### Steps

```bash
# Clone the repo
git clone https://github.com/abayeh/GitHubStatus.git
cd GitHubStatus

# Open in Xcode
open GitHubStatus.xcodeproj

# Build and run (Cmd+R in Xcode)
```

Or via command line:

```bash
xcodebuild -project GitHubStatus.xcodeproj -scheme GitHubStatus -configuration Debug build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/`.

## Architecture

```
GitHubStatus/
├── GitHubStatusApp.swift     # App entry point + AppDelegate (menu bar setup)
├── GitHubView.swift           # SwiftUI popover view
├── ComponentViewModel.swift  # @MainActor ObservableObject, async/await networking
├── Component.swift           # Codable data model for components
├── ComponentStatus.swift     # Status enum with color + display helpers
├── OverallStatus.swift       # Overall status response model
├── OverallIndicator.swift    # Status indicator enum (none/minor/major/critical)
├── BlendedStatus.swift       # Human-readable status enum
├── APIReponse.swift          # API response wrappers
└── Resources/
    └── Assets.xcassets        # App icon (GH initials)
```

### Key Design Decisions

- **Swift Concurrency** — Uses `async/await` and `@MainActor` instead of Combine callbacks
- **Menu Bar only** — No dock icon (`LSUIElement = true`), single status item
- **Graceful degradation** — Component and overall status fetches are independent; one failure doesn't block the other
- **New API fields** — `showcase`, `start_date`, `group_id`, `page_id` are decoded as optionals to handle future API changes

## Running Tests

```bash
xcodebuild test -project GitHubStatus.xcodeproj -scheme GitHubStatusTests
```

## License

MIT — see LICENSE file.
