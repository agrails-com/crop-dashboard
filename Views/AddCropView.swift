import SwiftUI

struct AddCropView: View {

  @Environment(\.dismiss)
  var dismiss

  @ObservedObject var manager: CropManager

  @State private var name = ""
  @State private var cropType = ""
  @State private var area = ""

  @State private var date = Date()

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

          DatePicker(
            "Planting Date",
            selection: $date,
            displayedComponents: .date
          )
        }

        Button("Save Crop") {

          guard
            let hectares =
              Double(area)
          else {
            return
          }

          manager.addCrop(
            name: name,
            type: cropType,
            area: hectares,
            date: date
          )

          dismiss()
        }

      }

      .navigationTitle(
        "Add Crop"
      )
    }
  }
}
