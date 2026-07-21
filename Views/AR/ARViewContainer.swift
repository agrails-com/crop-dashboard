import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {

  let zones: [Zone]
  @Binding var selectedZone: Zone?
  let coordinatorHolder: ARCoordinatorHolder

  func makeCoordinator() -> ARCoordinator {
    let coordinator = ARCoordinator(zones: zones)
    coordinator.onZoneSelected = { zone in
      selectedZone = zone
    }
    coordinatorHolder.coordinator = coordinator
    return coordinator
  }

  func makeUIView(context: Context) -> ARView {
    let view = ARView(frame: .zero)

    context.coordinator.startSession(view: view)

    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(ARCoordinator.handleTap(_:))
    )
    view.addGestureRecognizer(tapGesture)

    return view
  }

  func updateUIView(_ uiView: ARView, context: Context) {
    // AR overlay state is driven entirely by ARCoordinator via
    // ARSessionDelegate callbacks + tap gestures — intentionally not synced here.
  }

  static func dismantleUIView(_ uiView: ARView, coordinator: ARCoordinator) {
    uiView.session.pause()
  }
}
