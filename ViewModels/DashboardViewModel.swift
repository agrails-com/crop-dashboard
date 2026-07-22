import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {

  @Published var zones: [Zone] = []

  @Published var farms: [Farm] = []

  @Published var loading = false

  @Published var errorMessage: String?

  private let service =
    DataService()

  func loadData() async {

    loading = true
    errorMessage = nil

    do {

      let data =
        try await service.fetchZones()

      zones = data

      farms = [

        Farm(
          id: "farm1",
          name: "Kiambu Farm",
          location: "Kiambu, Kenya",
          zones: data
        )

      ]

    } catch {

      errorMessage =
        error.localizedDescription

    }

    loading = false

  }

  var healthy: Int {

    zones.filter {
      $0.status == .healthy
    }.count

  }

  var warning: Int {

    zones.filter {
      $0.status == .warning
    }.count

  }

  var critical: Int {

    zones.filter {
      $0.status == .critical
    }.count

  }

}
