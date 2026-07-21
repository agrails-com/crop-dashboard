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

        HStack {

          metric(
            "NDVI",
            "\(zone.ndvi)"
          )

          metric(
            "Moisture",
            "\(zone.moisture)"
          )

        }

        Chart {

          ForEach(
            Array(
              zone.history.enumerated()
            ),
            id: \.offset
          ) { index, value in

            LineMark(

              x:
                .value(
                  "Day",
                  index
                ),

              y:
                .value(
                  "NDVI",
                  value
                )

            )

          }

        }

        .frame(height: 220)

        Text(
          zone.analytics.recommendation
        )
        .padding()

      }

      .padding()

    }

  }

  func metric(
    _ title: String,
    _ value: String
  ) -> some View {

    VStack {

      Text(value)
        .font(.title.bold())

      Text(title)
        .foregroundColor(.secondary)

    }

    .frame(maxWidth: .infinity)

  }

}
