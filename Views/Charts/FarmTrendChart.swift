import Charts
import SwiftUI

struct FarmTrendChart: View {

  let zones: [Zone]

  var body: some View {

    VStack(alignment: .leading) {

      Text("NDVI Trend")
        .font(.headline)

      Chart {

        ForEach(
          zones
        ) { zone in

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
                  zone.name,
                  value
                )

            )

          }

        }

      }

      .frame(height: 250)

    }

  }

}
