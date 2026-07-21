# CropDashboard

A native iOS SwiftUI app that displays crop/field health data for a farm and overlays it in AR on a printed farm map, using ARKit image tracking and RealityKit.

## What it does

- **Dashboard tab** — a farm overview (zone/field counts, total hectares), a health-distribution pie chart, an NDVI trend chart, a MapKit view pinning each zone at its real coordinates, and a per-zone detail screen (NDVI/moisture metrics, history chart, recommendation).
- **AR Field View tab** — point the camera at a printed copy of the farm map; once ARKit recognizes it, each field is drawn as a colored polygon (green/orange/red by health status) anchored to the map, with a floating label card per zone. Tapping a zone slides up an analytics panel.

## Requirements

- Xcode 26 or later, iOS 26.4 deployment target.
- **A real iOS device with a camera to use the AR tab.** ARKit image tracking cannot run in the iOS Simulator — the Dashboard tab works fine in the simulator, but `ARFarmView` requires physical hardware.
- To actually see the AR overlay, you need a printout of the reference image registered in `Assets.xcassets` → "AR Resources" → `FarmMap`.

## Setup

1. Clone the repo and open `CropDashboard.xcodeproj` in Xcode.
2. Select the `CropDashboard` scheme.
3. For the Dashboard tab: run on the simulator or a device.
4. For the AR tab: run on a real device, then point the camera at a printed `FarmMap` image.

There's no backend and no build configuration needed — `Resources/zones.json` is bundled sample data, not a live feed (see [Data model](#data-model) below).

## Architecture

MVVM, with `DashboardViewModel` as the single shared source of truth passed down from `ContentView` into both the Dashboard and AR tabs.

- **Models/** — `Zone` is the core domain entity (one per field), decoded directly from `Resources/zones.json` and mirroring its schema (ndvi, moisture, temperature, `Analytics`, `Weather`, plus AR-specific `arPosition`/`arBoundary`). `ZoneStatus` is a `healthy`/`warning`/`critical` enum backing `Zone.status` — decoding fails loudly if `zones.json` ever contains an unrecognized status string, rather than silently falling through to a default color. `Farm` wraps a list of zones. `Crop` is a separate, user-entered entity (see `CropManager` below) unrelated to `Zone`.
- **Services/DataService** — loads and decodes `zones.json` from the app bundle. No network calls are made anywhere in the app.
- **ViewModels/DashboardViewModel** — loads zones via `DataService` and synthesizes a single hardcoded `Farm` ("Kiambu Farm") from them; exposes `healthy`/`warning`/`critical` counts derived from `zone.status`.
- **ViewModels/CropManager** — separate, unrelated to Zone/Farm data: persists user-added `Crop` entries to `UserDefaults` (via `AddCropView`).
- **Views/** — `DashboardView` is the navigation root, using a `NavigationStack` with a `DashboardRoute` enum (`.navigationDestination(for:)`) rather than per-screen `NavigationLink(destination:)`. `Views/Charts/` holds Swift Charts wrappers (`HealthDistributionChart`, `FarmTrendChart`) reused by both `DashboardView` and `FarmOverviewView`. `MapView` shows zones on a real-world MapKit map (separate from the AR map).
- **Views/AR/** — the AR subsystem, built on ARKit image tracking against the "AR Resources" reference image group in `Assets.xcassets` (a single `FarmMap` image). Key pieces:
  - `ARViewContainer` (`UIViewRepresentable`) creates the `ARView` and an `ARCoordinator` in `makeCoordinator()`.
  - `ARCoordinator` (`ARSessionDelegate`) runs the image-tracking session, publishes `trackingState` (`.notDetected` / `.tracking` / `.lost`), and builds one `ZoneEntity` per zone anchored to the detected image on `didAdd`.
  - `ZoneEntity` builds its mesh from `zone.arBoundary` (a digitized polygon, triangulated via `PolygonTriangulator`'s ear-clipping algorithm) when present, falling back to a simple rectangle from `zone.arPosition` otherwise. It also renders a billboarded label using a texture drawn by `LabelCardRenderer`.
  - `ARCoordinatorHolder` bridges the coordinator (created inside `makeCoordinator()`) up to `ARFarmView`, so the "Scan Farm Map" / rescan button can reach it.
  - `ARFarmView` is the top-level AR screen: full-screen camera view that shrinks to the top half and reveals a `ZoneAnalyticsPanel` when a zone is tapped.
- `ContentView` hosts a `TabView` (Dashboard / AR Field View). `ARTabContent` guards the AR tab so `ARFarmView` (and its camera session) is only instantiated while that tab is actually selected — otherwise the camera would keep running in the background while viewing the Dashboard tab.

### Data model

`zones.json` is the single source of truth for both the Dashboard/MapKit views and the AR overlay geometry — `arPosition`/`arBoundary` in that same file drive where each zone's shape is drawn in AR. It's static sample data bundled with the app, not fetched from any server.

## Known limitations

- No unit/UI test target.
- Single hardcoded farm ("Kiambu Farm") — not built for multi-farm use.
- `zones.json` is static; there's no live data pipeline behind the dashboard.

## License

MIT — see [LICENSE](LICENSE).
