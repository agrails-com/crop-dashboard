import Foundation

struct Crop: Identifiable, Codable {

  let id: UUID

  let name: String

  let variety: String

  let plantingDate: Date

  let areaHectares: Double
}
