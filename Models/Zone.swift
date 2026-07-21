import CoreLocation
import Foundation

struct Zone: Identifiable, Codable {

  let id: String

  let name: String
  let cropType: String

  let areaHectares: Double

  let ndvi: Double
  let moisture: Double
  let temperature: Double

  let status: ZoneStatus

  let latitude: Double
  let longitude: Double

  let history: [Double]
  let historyDates: [String]

  let analytics: Analytics

  let weather: Weather?

  /// Legacy rectangular placement — used as a fallback for zones that
  /// haven't been digitized into a real boundary polygon yet.
  let arPosition: ARPosition?

  /// Real field boundary, normalized (0-1) against the reference image's
  /// pixel space (origin top-left, y increases downward). Used instead of
  /// arPosition for rendering whenever present.
  let arBoundary: [ARBoundaryPoint]?
}

enum ZoneStatus: String, Codable, CaseIterable {
  case healthy
  case warning
  case critical

  var displayName: String {
    rawValue.capitalized
  }
}

struct Analytics: Codable {
  let trend: String
  let ndviChange: Double
  let ndviChangePercent: Double
  let moistureStatus: String
  let healthScore: Int
  let alertLevel: String
  let recommendation: String
}

struct Weather: Codable {
  let temperature: Double
  let humidity: Int
  let precipitationMm: Double
  let forecastRisk: String
}

struct ARPosition: Codable {
  let x: Float
  let y: Float
  let width: Float
  let height: Float
}

struct ARBoundaryPoint: Codable {
  let x: Double
  let y: Double
}

// MARK: - Equatable

extension Zone: Equatable {
  /// Two zones are considered equal if their IDs match, regardless of
  /// whether transient sensor values (ndvi, moisture, etc.) differ.
  /// Required for SwiftUI's .animation(_:value:) and similar APIs.
  static func == (lhs: Zone, rhs: Zone) -> Bool {
    lhs.id == rhs.id
  }
}
