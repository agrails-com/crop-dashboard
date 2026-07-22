import SwiftUI

struct CropRowView: View {
  let crop: Crop
  let zoneName: String?
  let onEdit: () -> Void
  let onDelete: () -> Void

  @State private var showDeleteConfirmation = false

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

        if let zoneName {
          Text("Linked to \(zoneName)")
            .font(.caption)
            .foregroundColor(.blue)
        }
      }

      Spacer()

      Button(action: onEdit) {
        Image(systemName: "pencil")
      }
      .buttonStyle(.borderless)

      Button(role: .destructive) {
        showDeleteConfirmation = true
      } label: {
        Image(systemName: "trash")
      }
      .buttonStyle(.borderless)
    }
    .padding()
    .background(.thinMaterial)
    .cornerRadius(15)
    .confirmationDialog(
      "Delete \(crop.name)?",
      isPresented: $showDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive, action: onDelete)
      Button("Cancel", role: .cancel) {}
    }
  }
}
