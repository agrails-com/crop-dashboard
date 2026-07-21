import MapKit
import SwiftUI

struct MapView: View {

  let zones: [Zone]

  @State private var position: MapCameraPosition = .automatic
  @State private var selectedZone: Zone?

  var body: some View {

    Map(position: $position) {

      ForEach(zones) { zone in

        Annotation(
          zone.name,
          coordinate: CLLocationCoordinate2D(
            latitude: zone.latitude,
            longitude: zone.longitude
          )
        ) {

          VStack(spacing: 4) {

            Circle()
              .fill(statusColor(for: zone.status))
              .frame(width: 22, height: 22)
              .overlay(
                Circle()
                  .stroke(.white, lineWidth: 2)
              )
              .shadow(radius: 4)

            Text(zone.name)
              .font(.caption2)
              .padding(4)
              .background(.ultraThinMaterial)
              .cornerRadius(6)
          }
          .onTapGesture {

            selectedZone = zone

            withAnimation {

              position = .region(
                MKCoordinateRegion(
                  center: CLLocationCoordinate2D(
                    latitude: zone.latitude,
                    longitude: zone.longitude
                  ),
                  span: MKCoordinateSpan(
                    latitudeDelta: 0.02,
                    longitudeDelta: 0.02
                  )
                )
              )
            }
          }
        }
      }
    }
    .navigationTitle("Field Map")
    .sheet(item: $selectedZone) { zone in

      ZoneDetailView(zone: zone)
    }
  }

  func statusColor(for status: ZoneStatus) -> Color {

    switch status {

    case .healthy:
      return .green

    case .warning:
      return .orange

    case .critical:
      return .red
    }
  }
}

#Preview {

  NavigationStack {

    MapView(
      zones: [
        Zone(
          id: "Z1",
          name: "North Field",
          cropType: "Maize",
          areaHectares: 12.4,
          ndvi: 0.72,
          moisture: 0.54,
          temperature: 21.5,
          status: .healthy,
          latitude: -1.2921,
          longitude: 36.8219,
          history: [0.65, 0.68, 0.70, 0.72],
          historyDates: [
            "2026-05-12",
            "2026-05-19",
            "2026-05-26",
            "2026-06-02",
          ],
          analytics: Analytics(
            trend: "improving",
            ndviChange: 0.07,
            ndviChangePercent: 10.8,
            moistureStatus: "adequate",
            healthScore: 66,
            alertLevel: "none",
            recommendation: "Continue routine monitoring."
          ),
          weather: Weather(
            temperature: 21.5,
            humidity: 68,
            precipitationMm: 4.2,
            forecastRisk: "low"
          ),
          arPosition: ARPosition(
            x: 0.25,
            y: 0.20,
            width: 0.35,
            height: 0.25

          ),
          arBoundary: nil
        )
      ]
    )
  }
}
