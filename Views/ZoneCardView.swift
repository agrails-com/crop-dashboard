import SwiftUI

struct ZoneCardView: View {

  let zone: Zone

  var body: some View {

    HStack {

      VStack(
        alignment: .leading,
        spacing: 8
      ) {

        Text(zone.name)
          .font(.headline)

        Text(zone.cropType)

        Text(
          "NDVI \(zone.ndvi, specifier:"%.2f")"
        )

      }

      Spacer()

      Circle()
        .fill(statusColor)
        .frame(
          width: 20,
          height: 20
        )

    }

    .padding()

    .background(.thinMaterial)

    .cornerRadius(15)

  }

  var statusColor: Color {

    switch zone.status {

    case .healthy:

      return .green

    case .warning:

      return .orange

    case .critical:

      return .red

    }

  }

}
