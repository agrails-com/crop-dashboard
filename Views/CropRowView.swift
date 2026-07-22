import SwiftUI

struct CropRowView: View {
  let crop: Crop
  let linkedZone: Zone?
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

        if let linkedZone {
          NavigationLink(value: DashboardRoute.zoneDetail(linkedZone.id)) {
            HStack(spacing: 4) {
              Circle()
                .fill(statusColor(linkedZone.status))
                .frame(width: 8, height: 8)
                .accessibilityLabel("\(linkedZone.status.displayName) status")

              Text("\(linkedZone.name) · \(linkedZone.status.displayName)")
                .font(.caption)

              Image(systemName: trendIcon(linkedZone.analytics.trend).systemName)
                .font(.caption)
                .foregroundColor(trendIcon(linkedZone.analytics.trend).color)
            }
          }
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

  private func statusColor(_ status: ZoneStatus) -> Color {
    switch status {
    case .healthy:
      return .green
    case .warning:
      return .orange
    case .critical:
      return .red
    }
  }

  private func trendIcon(_ trend: String) -> (systemName: String, color: Color) {
    switch trend.lowercased() {
    case "improving":
      return ("arrow.up.circle.fill", .green)
    case "declining":
      return ("arrow.down.circle.fill", .red)
    default:
      return ("arrow.right.circle.fill", .gray)
    }
  }
}
