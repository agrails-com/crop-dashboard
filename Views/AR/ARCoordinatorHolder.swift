import Combine
import SwiftUI

/// Bridges the ARCoordinator (created inside ARViewContainer's
/// makeCoordinator) up to ARFarmView, so the "Scan Farm Map" button
/// can call rescan() without restructuring the view hierarchy.
final class ARCoordinatorHolder: ObservableObject {
  var coordinator: ARCoordinator?
}
