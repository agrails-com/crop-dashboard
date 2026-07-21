import SwiftUI

struct FarmCardView: View {

  let farm: Farm

  var body: some View {

    VStack(alignment: .leading, spacing: 12) {

      Text(farm.name)
        .font(.title2.bold())

      Text(farm.location)
        .foregroundColor(.secondary)

      HStack {

        VStack {

          Text("\(farm.zones.count)")
            .font(.title.bold())

          Text("Zones")

        }

        Spacer()

        VStack {

          Text(
            String(
              format: "%.1f",
              farm.totalArea
            )
          )
          .font(.title.bold())

          Text("Hectares")

        }

      }

    }
    .padding()
    .background(.thinMaterial)
    .cornerRadius(20)

  }

}
