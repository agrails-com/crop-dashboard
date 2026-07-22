import Charts
import SwiftUI

struct ZoneDetailView: View {

  let zone: Zone

  var body: some View {

    ScrollView {

      VStack(spacing: 20) {

        Text(zone.name)
          .font(.largeTitle.bold())

        Text(zone.cropType)
          .foregroundColor(.secondary)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
          metricCard("NDVI", String(format: "%.2f", zone.ndvi))
          metricCard("Moisture", "\(Int(zone.moisture * 100))%")
          metricCard("Temperature", String(format: "%.1f°C", zone.temperature))
          metricCard("Area", String(format: "%.1f ha", zone.areaHectares))
          metricCard("Health Score", "\(zone.analytics.healthScore)/100")
          metricCard("Trend", zone.analytics.trend.capitalized)
        }

        Chart {

          ForEach(
            Array(
              zone.history.enumerated()
            ),
            id: \.offset
          ) { index, value in

            LineMark(
              x: .value("Day", index),
              y: .value("NDVI", value)
            )

          }

        }
        .frame(height: 220)

        VStack(alignment: .leading, spacing: 10) {
          Text("Analytics")
            .font(.headline)

          detailRow("Moisture status", zone.analytics.moistureStatus.capitalized)
          detailRow("NDVI change", String(format: "%+.1f%%", zone.analytics.ndviChangePercent))
          detailRow("Alert level", zone.analytics.alertLevel.capitalized)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(15)

        if let weather = zone.weather {
          VStack(alignment: .leading, spacing: 10) {
            Text("Weather")
              .font(.headline)

            detailRow("Temperature", String(format: "%.1f°C", weather.temperature))
            detailRow("Humidity", "\(weather.humidity)%")
            detailRow("Precipitation", String(format: "%.1f mm", weather.precipitationMm))
            detailRow("Forecast risk", weather.forecastRisk.capitalized)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(.thinMaterial)
          .cornerRadius(15)
        }

        VStack(alignment: .leading, spacing: 6) {
          Text("Recommendation")
            .font(.headline)

          Text(zone.analytics.recommendation)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()

      }
      .padding()

    }

  }

  private func metricCard(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)

      Text(value)
        .font(.subheadline.bold())
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(10)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(10)
  }

  private func detailRow(_ label: String, _ value: String) -> some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)

      Spacer()

      Text(value)
        .fontWeight(.medium)
    }
  }

}
