import SwiftUI

struct FarmOverview: View {

  let farm: Farm

  var body: some View {

    ScrollView {

      VStack(spacing: 20) {

        Text(farm.name)
          .font(.largeTitle.bold())

        Text(farm.location)
          .foregroundColor(.secondary)

        HealthDistributionChart(
          zones: farm.zones
        )

        FarmTrendChart(
          zones: farm.zones
        )

        Text("Fields")
          .font(.title2.bold())
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )

        ForEach(farm.zones) { zone in

          NavigationLink {

            ZoneDetailView(
              zone: zone
            )

          } label: {

            ZoneCardView(
              zone: zone
            )

          }

        }

      }
      .padding()

    }

  }

}
