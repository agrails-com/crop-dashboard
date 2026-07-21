import SwiftUI

struct CropRowView: View {
  let crop: Crop
  let onDelete: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(crop.name)
          .font(.headline)

        Text(crop.variety)
          .foregroundColor(.secondary)

        Text(
          "\(crop.areaHectares, specifier: "%.1f") ha · Planted \(crop.plantingDate.formatted(date: .abbreviated, time: .omitted))"
        )
        .font(.caption)
        .foregroundColor(.secondary)
      }

      Spacer()

      Button(role: .destructive, action: onDelete) {
        Image(systemName: "trash")
      }
      .buttonStyle(.borderless)
    }
    .padding()
    .background(.thinMaterial)
    .cornerRadius(15)
  }
}
