import Foundation

struct CropHealthResponse: Codable {
  let meta: Meta
  let zones: [Zone]
}

struct Meta: Codable {
  let farmName: String
  let dataSource: String
  let lastSync: String
  let ndviScale: String
  let summary: Summary
}

struct Summary: Codable {
  let totalZones: Int
  let averageNdvi: Double
  let healthyCount: Int
  let warningCount: Int
  let criticalCount: Int
}
