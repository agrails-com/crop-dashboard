import Combine
import Foundation
import SwiftUI

@MainActor
final class CropManager: ObservableObject {

  @Published var crops: [Crop] = []

  private let key = "saved_crops"

  init() {

    load()
  }

  func addCrop(
    name: String,
    type: String,
    area: Double,
    date: Date,
    zoneID: String? = nil
  ) {

    let crop = Crop(
      id: UUID(),
      name: name,
      variety: type,
      plantingDate: date,
      areaHectares: area,
      zoneID: zoneID
    )

    crops.append(crop)

    save()
  }

  func deleteCrop(
    at offsets: IndexSet
  ) {

    crops.remove(atOffsets: offsets)

    save()
  }

  func updateCrop(_ updated: Crop) {

    guard let index = crops.firstIndex(where: { $0.id == updated.id }) else { return }

    crops[index] = updated

    save()
  }

  func save() {

    if let data =
      try? JSONEncoder()
      .encode(crops)
    {

      UserDefaults.standard.set(
        data,
        forKey: key
      )
    }
  }

  func load() {

    guard
      let data =
        UserDefaults.standard.data(
          forKey: key
        )
    else {
      return
    }

    crops =
      (try? JSONDecoder()
        .decode(
          [Crop].self,
          from: data
        ))
      ?? []
  }
}
