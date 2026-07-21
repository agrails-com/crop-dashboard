import ARKit
import RealityKit
import SwiftUI

struct ARFarmView: View {

  @ObservedObject var viewModel: DashboardViewModel

  @State private var selectedZone: Zone?
  @StateObject private var coordinatorHolder = ARCoordinatorHolder()

  var body: some View {

    GeometryReader { geo in
      VStack(spacing: 0) {

        ZStack {
          ARViewContainer(
            zones: viewModel.zones,
            selectedZone: $selectedZone,
            coordinatorHolder: coordinatorHolder
          )
          .ignoresSafeArea(edges: selectedZone == nil ? .all : [])

          VStack {

            HStack(spacing: 15) {

              Circle()
                .fill(.green)
                .frame(width: 12, height: 12)

              Text("Healthy")

              Circle()
                .fill(.yellow)
                .frame(width: 12, height: 12)

              Text("Warning")

              Circle()
                .fill(.red)
                .frame(width: 12, height: 12)

              Text("Critical")
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(25)

            // Clear message whenever the map isn't detected or
            // tracking is lost — never just a blank camera view.
            // Animation is scoped to this text only (not the
            // surrounding VStack) so it doesn't force layout
            // recalculation of the whole overlay on every
            // trackingState publish.
            if let hint = detectionHint {
              Text(hint)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.top, 12)
                .transition(.opacity)
                .animation(
                  .easeInOut(duration: 0.25), value: coordinatorHolder.coordinator?.trackingState)
            }

            Spacer()

            if selectedZone == nil {
              Button {
                coordinatorHolder.coordinator?.rescan()
              } label: {
                Text("Scan Farm Map")
                  .font(.headline)
                  .padding()
                  .frame(width: 220)
                  .background(.ultraThinMaterial)
                  .cornerRadius(20)
              }
              .padding(.bottom, 30)
            }
          }
          .padding()
        }
        .frame(height: selectedZone == nil ? geo.size.height : geo.size.height * 0.5)
        .animation(.easeInOut(duration: 0.3), value: selectedZone)

        if let zone = selectedZone {
          ZoneAnalyticsPanel(zone: zone) {
            withAnimation { selectedZone = nil }
          }
          .frame(height: geo.size.height * 0.5)
          .transition(.move(edge: .bottom))
        }
      }
      .task {
        if viewModel.zones.isEmpty {
          await viewModel.loadData()
        }
      }
    }
  }

  private var detectionHint: String? {
    switch coordinatorHolder.coordinator?.trackingState {
    case .notDetected, .none:
      return "Point your camera at the printed farm map"
    case .lost:
      return "Map lost — move the camera back into view"
    case .tracking:
      return nil
    }
  }
}

/// Split-screen analytics panel shown when a zone is tapped in AR.
/// Swap in your existing ZoneDetailView / ZoneCardView here if you'd
/// rather reuse those instead of this inline layout.
struct ZoneAnalyticsPanel: View {
  let zone: Zone
  let onClose: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(zone.name).font(.title2.bold())
            Text(zone.cropType).font(.caption).foregroundStyle(.secondary)
          }
          Spacer()
          Button(action: onClose) {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.secondary)
              .font(.title3)
          }
        }

        Text(zone.status.displayName)
          .font(.subheadline.bold())
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(8)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
          metric("NDVI", String(format: "%.2f", zone.ndvi))
          metric("Health Score", "\(zone.analytics.healthScore)/100")
          metric("Moisture", "\(Int(zone.moisture * 100))%")
          metric("Temperature", String(format: "%.1f°C", zone.temperature))
          metric("Area", String(format: "%.1f ha", zone.areaHectares))
          metric("Trend", zone.analytics.trend.capitalized)
        }

        VStack(alignment: .leading, spacing: 6) {
          Text("Recommendation").font(.headline)
          Text(zone.analytics.recommendation)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer(minLength: 8)
      }
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
  }

  private func metric(_ label: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label).font(.caption).foregroundStyle(.secondary)
      Text(value).font(.subheadline.bold())
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(10)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(10)
  }
}
