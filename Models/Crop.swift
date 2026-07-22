import Foundation

struct Crop: Identifiable, Codable {

  let id: UUID

  let name: String

  let variety: String

  let plantingDate: Date

  let areaHectares: Double

  /// Optional link to a Zone.id. Optional so crops saved before this field
  /// existed still decode fine from UserDefaults.
  let zoneID: String?
}
