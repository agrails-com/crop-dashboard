# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

CropDashboard is a native iOS SwiftUI app (bundle ID `Divine.CropDashboard`, Swift 5.0, iOS 26.4 deployment target) that displays crop/field health data for a farm and overlays it in AR on a printed farm map using ARKit image tracking + RealityKit. There is a single Xcode target — no test target, no SPM/CocoaPods dependencies.

## Common commands

Build and run from Xcode normally (`CropDashboard.xcodeproj`, scheme `CropDashboard`). From the CLI:

```bash
# Build for the simulator
xcodebuild -project CropDashboard.xcodeproj -scheme CropDashboard -sdk iphonesimulator build

# List available simulators (needed to pick a valid -destination)
xcrun simctl list devices available
```

Note: the AR tab (`ARFarmView`) requires a real device with a camera and ARKit support — it cannot be exercised in the iOS Simulator. There are currently no unit/UI tests in this project.

## Architecture

MVVM, with `DashboardViewModel` as the single shared source of truth passed down from `ContentView` into both the Dashboard and AR tabs.

- **Models/** — `Zone` is the core domain entity (one per field), decoded directly from `Resources/zones.json` and mirroring its schema (ndvi, moisture, temperature, `Analytics`, `Weather`, plus AR-specific `arPosition`/`arBoundary`). `Farm` wraps a list of zones. `Crop` is a separate, user-entered entity (see CropManager below) unrelated to `Zone`.
- **Services/DataService** — loads and decodes `zones.json` from the app bundle (no network calls). `Services/WeatherService` calls the open-meteo API but is currently not wired into any view model — `Zone.weather` comes from the static JSON, not a live fetch.
- **ViewModels/DashboardViewModel** — loads zones via `DataService` and synthesizes a single hardcoded `Farm` ("Kiambu Farm") from them; exposes `healthy`/`warning`/`critical` counts derived from `zone.status`.
- **ViewModels/CropManager** — separate, unrelated to Zone/Farm data: persists user-added `Crop` entries to `UserDefaults` (via `AddCropView`).
- **Views/** — `DashboardView` is the navigation root, using a `NavigationStack` with a `DashboardRoute` enum (`.navigationDestination(for:)`) rather than per-screen `NavigationLink(destination:)`. `Views/Charts/` holds Swift Charts wrappers (`HealthDistributionChart`, `FarmTrendChart`) reused by both `DashboardView` and `FarmOverviewView`. `MapView` shows zones on a real-world `MapKit` map (separate from the AR map).
- **Views/AR/** — the AR subsystem, built on ARKit image tracking against the "AR Resources" reference image group in `Assets.xcassets` (a single `FarmMap` image). Key pieces and how they connect:
  - `ARViewContainer` (`UIViewRepresentable`) creates the `ARView` and an `ARCoordinator` in `makeCoordinator()`.
  - `ARCoordinator` (`ARSessionDelegate`) runs the image-tracking session, publishes `trackingState` (`.notDetected` / `.tracking` / `.lost`), and builds one `ZoneEntity` per zone anchored to the detected image on `didAdd`.
  - `ZoneEntity` builds its mesh from `zone.arBoundary` (a real digitized polygon, triangulated via `PolygonTriangulator`'s ear-clipping algorithm) when present, falling back to a simple rectangle from `zone.arPosition` otherwise. It also renders a billboarded label using a texture drawn by `LabelCardRenderer`.
  - `ARCoordinatorHolder` is a small bridge object: since `ARCoordinator` is created inside `makeCoordinator()` (owned by the `UIViewRepresentable` internals), `ARFarmView` needs this holder to reach the coordinator instance for the "Scan Farm Map" / rescan button.
  - `ARFarmView` is the top-level AR screen: full-screen camera view that shrinks to the top half and reveals a `ZoneAnalyticsPanel` when a zone is tapped.
- `ContentView` hosts a `TabView` (Dashboard / AR Field View). `ARTabContent` guards the AR tab so `ARFarmView` (and its camera session) is only instantiated while that tab is actually selected — `TabView` otherwise keeps all tab content alive, which would leave the camera running in the background.

## Data flow gotchas

- `zones.json` is the single source of truth for both the Dashboard/MapKit views and the AR overlay geometry — `arPosition`/`arBoundary` in that same file drive where each zone's shape is drawn in AR.
- `Zone.status` is a free-form string (`"healthy"` / `"warning"` / `"critical"`) checked with `==` in several places (`DashboardViewModel`, chart views, `ZoneEntity.colorForStatus`, `MapView.statusColor`) rather than a shared enum — keep new status-dependent UI consistent with the existing string values if you add one.
