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
  @State private var editingCrop: Crop?

  var body: some View {

    NavigationStack {

      ScrollView {

        VStack(spacing: 20) {

          Text("Agrails Dashboard")
            .font(.largeTitle.bold())

          if viewModel.loading {
            ProgressView("Loading farm data…")
              .padding()
          }

          if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 8) {
              Text("Couldn't load farm data")
                .font(.headline)

              Text(errorMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

              Button("Retry") {
                Task { await viewModel.loadData() }
              }
              .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .cornerRadius(15)
          }

          if !attentionZones.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
              Text("Needs Attention")
                .font(.title2.bold())

              ForEach(attentionZones) { zone in
                NavigationLink(value: DashboardRoute.zoneDetail(zone.id)) {
                  HStack {
                    VStack(alignment: .leading, spacing: 2) {
                      Text(zone.name)
                        .font(.headline)

                      Text(zone.analytics.recommendation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(zone.analytics.alertLevel.capitalized)
                      .font(.caption.bold())
                      .padding(.horizontal, 10)
                      .padding(.vertical, 4)
                      .background(alertColor(zone.analytics.alertLevel).opacity(0.2))
                      .foregroundColor(alertColor(zone.analytics.alertLevel))
                      .cornerRadius(8)
                  }
                  .padding()
                  .background(.thinMaterial)
                  .cornerRadius(15)
                }
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }

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

          Text("My Crops")
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)

          if cropManager.crops.isEmpty {
            Text("No crops added yet. Tap \"Add Crop\" below to get started.")
              .font(.subheadline)
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
          } else {
            ForEach(cropManager.crops) { crop in
              CropRowView(
                crop: crop,
                zoneName: viewModel.zones.first(where: { $0.id == crop.zoneID })?.name,
                onEdit: { editingCrop = crop }
              ) {
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
      .refreshable {
        await viewModel.loadData()
      }
      .sheet(item: $editingCrop) { crop in
        AddCropView(manager: cropManager, zones: viewModel.zones, editingCrop: crop)
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

          AddCropView(manager: cropManager, zones: viewModel.zones)
        }
      }
    }
  }

  private var attentionZones: [Zone] {
    viewModel.zones.filter { $0.analytics.alertLevel.lowercased() != "none" }
  }

  private func alertColor(_ level: String) -> Color {
    switch level.lowercased() {
    case "high":
      return .red
    case "medium":
      return .orange
    default:
      return .yellow
    }
  }
}
