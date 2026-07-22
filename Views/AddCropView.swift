import SwiftUI

struct AddCropView: View {

  @Environment(\.dismiss)
  var dismiss

  @ObservedObject var manager: CropManager
  let zones: [Zone]
  let editingCrop: Crop?

  @State private var name: String
  @State private var cropType: String
  @State private var area: String

  @State private var date: Date
  @State private var selectedZoneID: String?

  @State private var areaErrorMessage: String?

  init(manager: CropManager, zones: [Zone], editingCrop: Crop? = nil) {
    self.manager = manager
    self.zones = zones
    self.editingCrop = editingCrop

    _name = State(initialValue: editingCrop?.name ?? "")
    _cropType = State(initialValue: editingCrop?.variety ?? "")
    _area = State(initialValue: editingCrop.map { String($0.areaHectares) } ?? "")
    _date = State(initialValue: editingCrop?.plantingDate ?? Date())
    _selectedZoneID = State(initialValue: editingCrop?.zoneID)
  }

  var body: some View {

    NavigationStack {

      Form {

        Section("Crop Information") {

          TextField(
            "Field Name",
            text: $name
          )

          TextField(
            "Crop Type",
            text: $cropType
          )

          TextField(
            "Area hectares",
            text: $area
          )
          .keyboardType(.decimalPad)

          if let areaErrorMessage {
            Text(areaErrorMessage)
              .font(.caption)
              .foregroundColor(.red)
          }

          DatePicker(
            "Planting Date",
            selection: $date,
            displayedComponents: .date
          )

          Picker("Zone (optional)", selection: $selectedZoneID) {
            Text("None")
              .tag(nil as String?)

            ForEach(zones) { zone in
              Text(zone.name)
                .tag(zone.id as String?)
            }
          }
        }

        Button(editingCrop == nil ? "Save Crop" : "Update Crop") {

          guard
            let hectares = Double(area),
            hectares > 0
          else {
            areaErrorMessage = "Enter a valid area in hectares"
            return
          }

          areaErrorMessage = nil

          if let editingCrop {
            manager.updateCrop(
              Crop(
                id: editingCrop.id,
                name: name,
                variety: cropType,
                plantingDate: date,
                areaHectares: hectares,
                zoneID: selectedZoneID
              )
            )
          } else {
            manager.addCrop(
              name: name,
              type: cropType,
              area: hectares,
              date: date,
              zoneID: selectedZoneID
            )
          }

          dismiss()
        }

      }

      .navigationTitle(
        editingCrop == nil ? "Add Crop" : "Edit Crop"
      )
    }
  }
}
