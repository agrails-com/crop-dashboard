import Foundation

final class DataService {

  func fetchZones()
    async throws -> [Zone]
  {

    guard
      let url =
        Bundle.main.url(
          forResource: "zones",
          withExtension: "json"
        )
    else {

      throw NSError(
        domain: "",
        code: 0,
        userInfo: [
          NSLocalizedDescriptionKey:
            "zones.json missing"
        ]
      )

    }

    let data =
      try Data(
        contentsOf: url
      )

    return try JSONDecoder()
      .decode(
        [Zone].self,
        from: data
      )

  }

}
