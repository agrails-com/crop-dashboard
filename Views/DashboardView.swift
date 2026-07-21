import SwiftUI

enum DashboardRoute: Hashable {
  case farmOverview(String)
  case farmMap
  case zoneDetail(String)
  case arFarmView
  case addCrop
}

struct DashboardView: View {
  @ObservedObject var viewModel: DashboardViewModel
  @StateObject private var cropManager = CropManager()

  var body: some View {

    NavigationStack {

      ScrollView {

        VStack(spacing: 20) {

          Text("Agrails Dashboard")
            .font(.largeTitle.bold())

          if let farm = viewModel.farms.first {
            NavigationLink(value: DashboardRoute.farmOverview(farm.id)) {
              FarmCardView(farm: farm)
            }
          }

          HealthDistributionChart(zones: viewModel.zones)

          FarmTrendChart(zones: viewModel.zones)

          NavigationLink(value: DashboardRoute.farmMap) {
            Label("Farm Map", systemImage: "map")
          }

          Text("Zones")
            .font(.title2.bold())

          ForEach(viewModel.zones) { zone in
            NavigationLink(value: DashboardRoute.zoneDetail(zone.id)) {
              ZoneCardView(zone: zone)
            }
          }

          NavigationLink(value: DashboardRoute.arFarmView) {
            Label("AR Field View", systemImage: "arkit")
          }

          if !cropManager.crops.isEmpty {
            Text("My Crops")
              .font(.title2.bold())
              .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(cropManager.crops) { crop in
              CropRowView(crop: crop) {
                if let index = cropManager.crops.firstIndex(where: { $0.id == crop.id }) {
                  cropManager.deleteCrop(at: IndexSet(integer: index))
                }
              }
            }
          }

          NavigationLink(value: DashboardRoute.addCrop) {
            Label("Add Crop", systemImage: "plus.circle")
          }
        }
        .padding()
      }
      .task {
        await viewModel.loadData()
      }
      .navigationDestination(for: DashboardRoute.self) { route in

        switch route {

        case .farmOverview(let farmID):

          if let farm = viewModel.farms.first(where: { $0.id == farmID }) {
            FarmOverview(farm: farm)
          } else {
            Text("Farm not found")
          }

        case .farmMap:

          MapView(zones: viewModel.zones)

        case .zoneDetail(let zoneID):

          if let zone = viewModel.zones.first(where: { $0.id == zoneID }) {
            ZoneDetailView(zone: zone)
          } else {
            Text("Zone not found")
          }

        case .arFarmView:

          ARFarmView(viewModel: viewModel)

        case .addCrop:

          AddCropView(manager: cropManager)
        }
      }
    }
  }
}
