import Charts
import SwiftUI

struct HealthDistributionChart: View {

  let zones: [Zone]

  var data: [HealthItem] {

    [

      HealthItem(
        name: "Healthy",
        count:
          zones.filter {
            $0.status == .healthy
          }.count
      ),

      HealthItem(
        name: "Warning",
        count:
          zones.filter {
            $0.status == .warning
          }.count
      ),

      HealthItem(
        name: "Critical",
        count:
          zones.filter {
            $0.status == .critical
          }.count
      ),

    ]

  }

  var body: some View {

    VStack(alignment: .leading) {

      Text("Farm Health Distribution")
        .font(.headline)

      Chart(data) { item in

        SectorMark(

          angle:
            .value(
              "Count",
              item.count
            )

        )

        .foregroundStyle(
          by:
            .value(
              "Status",
              item.name
            )
        )

      }

      .frame(height: 220)

    }

  }

}

struct HealthItem: Identifiable {

  let id = UUID()

  let name: String

  let count: Int

}
