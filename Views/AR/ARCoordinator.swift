import ARKit
import Combine
import RealityKit
import SwiftUI

final class ARCoordinator: NSObject, ARSessionDelegate, ObservableObject {

  weak var arView: ARView?
  let zones: [Zone]

  var onZoneSelected: ((Zone) -> Void)?

  @Published var trackingState: TrackingState = .notDetected

  enum TrackingState {
    case notDetected
    case tracking
    case lost
  }

  private var overlayAnchor: AnchorEntity?
  private var zoneEntities: [ZoneEntity] = []
  private var hasDetectedImage = false

  init(zones: [Zone]) {
    self.zones = zones
    super.init()
  }

  // MARK: - Session lifecycle

  func startSession(view: ARView) {
    arView = view
    view.session.delegate = self

    let config = ARImageTrackingConfiguration()

    guard let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
    else {
      #if DEBUG
        print("❌ No images")
      #endif
      return
    }

    config.trackingImages = images
    config.maximumNumberOfTrackedImages = 1

    view.session.run(config, options: [.resetTracking, .removeExistingAnchors])

    #if DEBUG
      print("✅ AR Started")
    #endif
  }

  /// Called by the "Scan Farm Map" button — restarts detection the same
  /// direct way startSession does.
  func rescan() {
    guard let view = arView else { return }

    overlayAnchor?.removeFromParent()
    overlayAnchor = nil
    zoneEntities.removeAll()
    hasDetectedImage = false
    trackingState = .notDetected

    startSession(view: view)
  }

  // MARK: - ARSessionDelegate

  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
      guard let imageAnchor = anchor as? ARImageAnchor else { continue }
      #if DEBUG
        print("🔥 IMAGE DETECTED:", imageAnchor.referenceImage.name ?? "unknown")
      #endif
      createMapOverlay(imageAnchor)
      hasDetectedImage = true
    }

    if trackingState != .tracking {
      trackingState = .tracking
    }
  }

  func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    var anyTracked = false
    for anchor in anchors {
      guard let imageAnchor = anchor as? ARImageAnchor else { continue }
      if imageAnchor.isTracked { anyTracked = true }
    }

    let newState: TrackingState =
      anyTracked ? .tracking : (hasDetectedImage ? .lost : trackingState)

    // Only publish when the value actually transitions — didUpdate fires
    // on nearly every frame (~60x/sec) while tracking, and unconditionally
    // reassigning a @Published property forces constant SwiftUI re-layout,
    // which was making the overlay appear to drift even though the
    // underlying anchor itself was stable.
    if newState != trackingState {
      trackingState = newState
    }
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    #if DEBUG
      print("❌ AR session failed: \(error.localizedDescription)")
    #endif
    if trackingState != .notDetected {
      trackingState = .notDetected
    }
  }

  // MARK: - Overlay construction

  private func createMapOverlay(_ imageAnchor: ARImageAnchor) {
    guard let view = arView else { return }

    // Guard against duplicate overlays if didAdd fires more than once.
    overlayAnchor?.removeFromParent()
    zoneEntities.removeAll()

    let anchor = AnchorEntity(anchor: imageAnchor)
    let imageSize = imageAnchor.referenceImage.physicalSize
    let mapRoot = Entity()

    for (index, zone) in zones.enumerated() {
      let zoneEntity = ZoneEntity(zone: zone, imageSize: imageSize)
      // Tiny per-zone Y offset avoids z-fighting on any coincident edges.
      zoneEntity.position.y = Float(index) * 0.0005
      mapRoot.addChild(zoneEntity)
      zoneEntities.append(zoneEntity)
    }

    anchor.addChild(mapRoot)
    view.scene.addAnchor(anchor)
    overlayAnchor = anchor

    #if DEBUG
      print("Overlay locked to map")
    #endif
  }

  // MARK: - Tap handling

  @objc func handleTap(_ sender: UITapGestureRecognizer) {
    guard let arView = arView else { return }
    let point = sender.location(in: arView)
    guard let hitEntity = arView.entity(at: point) else { return }

    if let zoneEntity = hitEntity as? ZoneEntity ?? hitEntity.parent as? ZoneEntity {
      onZoneSelected?(zoneEntity.zone)
    }
  }

  /// Recolors a live zone overlay without rebuilding geometry.
  func updateZoneStatus(zoneID: String, newStatus: ZoneStatus) {
    zoneEntities.first(where: { $0.zone.id == zoneID })?.updateStatus(newStatus)
  }
}
