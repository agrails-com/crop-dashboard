import Foundation

struct Farm: Identifiable {

  let id: String

  let name: String

  let location: String

  let zones: [Zone]

  var totalArea: Double {

    zones.reduce(0) {
      $0 + $1.areaHectares
    }

  }

}
