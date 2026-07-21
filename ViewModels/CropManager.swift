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
    date: Date
  ) {

    let crop = Crop(
      id: UUID(),
      name: name,
      variety: type,
      plantingDate: date,
      areaHectares: area

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
