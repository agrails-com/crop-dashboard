# Zone Health on Crop Cards

## Context

`Crop` entries can optionally link to a `Zone` (shipped in the "Extend Dashboard/Crop UX" work), and `CropRowView` currently shows that link as plain text: "Linked to North Field". That's purely informational — it doesn't surface whether the linked field is actually healthy, and it isn't tappable. This is the smallest of several "make the app better with what we already have" ideas explored in conversation (the others — AI Crop Advisor, Historical Comparison, Multi-Farm Management — were deliberately deferred as separate, larger sub-projects since they need new data or infrastructure this one doesn't).

Goal: turn that line into a live, actionable health indicator — status, trend, and a tap-through to the zone's detail screen — using only data the app already has (`Zone.status`, `Zone.analytics.trend`), no schema or infrastructure changes.

## Non-goals

- No changes to `zones.json` or any AR-related code.
- No changes to how crops are linked to zones (that mechanism already exists).
- Not building Historical Comparison, Multi-Farm Management, or AI Crop Advisor — those remain separate future sub-projects.

## Data flow

`DashboardView` already resolves a crop's linked zone by ID once per row (previously just to extract `.name`):

```swift
viewModel.zones.first(where: { $0.id == crop.zoneID })
```

That lookup is reused as-is, but the full `Zone?` is passed through instead of just its name:

```swift
CropRowView(
  crop: crop,
  linkedZone: viewModel.zones.first(where: { $0.id == crop.zoneID }),
  onEdit: { editingCrop = crop }
) { ... }
```

## Component changes

**`CropRowView`** (`Views/CropRowView.swift`):
- Replace the `zoneName: String?` parameter with `linkedZone: Zone?`.
- Where the "Linked to \(zoneName)" `Text` currently sits, replace it with (when `linkedZone != nil`):
  - A `NavigationLink(value: DashboardRoute.zoneDetail(zone.id))` wrapping an `HStack`:
    - A small filled `Circle` tinted by zone status (reuse the existing healthy/warning/critical → green/orange/red mapping already used in `ZoneCardView`/`MapView`).
    - `Text("\(zone.name) · \(zone.status.displayName)")`.
    - A trend `Image(systemName:)` icon (see Visual design below).
  - When `linkedZone == nil`, render nothing — identical to today's behavior for unlinked crops.
- `CropRowView` is rendered inside `DashboardView`'s existing `NavigationStack`, so `DashboardRoute.zoneDetail` resolves via the `.navigationDestination` modifier already there — no new navigation plumbing needed.

**`DashboardView`** (`Views/DashboardView.swift`): update the one `CropRowView(...)` call site to pass `linkedZone:` instead of `zoneName:`.

No other files change. `AddCropView`'s zone picker and `Crop.zoneID` are untouched.

## Visual design

- Row content: `[colored dot] Zone Name · Status [trend icon]` — e.g. 🟢 "North Field · Healthy ↑".
- Status dot/text color: reuse the existing health-status color mapping (green/warning-orange/critical-red).
- Trend icon: derived from `zone.analytics.trend` (a free-form `String`, not an enum):
  - `"improving"` → `arrow.up.circle.fill`, tinted green.
  - `"declining"` → `arrow.down.circle.fill`, tinted red.
  - anything else (unrecognized string, future value) → `arrow.right.circle.fill`, tinted gray (neutral default).
  - Trend color is independent of status color — a critical zone can be improving, a healthy one can be declining, so they must not share one color channel.
- Consistent with the existing accessibility pass on `MapView`/`ZoneCardView`'s status dots, this new dot also gets `.accessibilityLabel("\(zone.status.displayName) status")`.

## Navigation & tap targets

- The `NavigationLink` wraps only the zone-badge sub-row, not the entire `CropRowView` card. The existing edit (pencil) and delete (trash) buttons remain separate `Button`s in the same `HStack`, so there's no nested-tap-target conflict — tapping the badge navigates, tapping edit/delete does its own thing, same as they do today independent of each other.
- Destination: `ZoneDetailView` via `DashboardRoute.zoneDetail(zone.id)` — the same route already used by the Zones list and the "Needs Attention" section, so this is a consistent, already-proven navigation path, not a new one.

## Edge cases

- Crop has no `zoneID`, or `zoneID` no longer matches any zone in `viewModel.zones` (e.g. hypothetically removed from the data) → `linkedZone` resolves to `nil` → row renders with no zone line at all, same as an unlinked crop today. No crash, no placeholder text.
- `analytics.trend` value outside `"improving"`/`"declining"` → falls back to the neutral flat-arrow icon rather than guessing or crashing.

## Testing / verification

Same manual-verification approach used for prior features in this project (no test target exists yet):
1. `xcodebuild -project CropDashboard.xcodeproj -scheme CropDashboard -sdk iphonesimulator build` — confirm clean build.
2. Boot a simulator, seed a crop linked to a zone via the app's `UserDefaults` container (as done for earlier feature verification), launch, and screenshot:
   - Confirm the row shows the colored dot, zone name, status text, and correct trend arrow/color.
   - Confirm tapping the badge navigates to that zone's `ZoneDetailView`.
   - Confirm the edit and delete buttons on the same row still work independently (tapping the badge doesn't trigger them and vice versa).
3. Seed one crop with no `zoneID` and confirm its row is unchanged from current behavior (no extra line, no crash).
