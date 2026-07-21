import RealityKit
import UIKit

final class ZoneEntity: Entity {

  let zone: Zone
  private var modelEntity: ModelEntity?
  private var labelEntity: ModelEntity?

  init(zone: Zone, imageSize: CGSize) {
    self.zone = zone
    super.init()
    buildGeometry(imageSize: imageSize)
  }

  required init() {
    fatalError("init() has not been implemented")
  }

  private func buildGeometry(imageSize: CGSize) {
    let width = Float(imageSize.width)
    let height = Float(imageSize.height)

    var centroid = SIMD3<Float>(0, 0, 0)

    if let boundary = zone.arBoundary, boundary.count >= 3 {
      centroid = buildPolygonMesh(boundary, width: width, height: height)
    } else if let rect = zone.arPosition {
      centroid = buildRectangleMesh(rect, width: width, height: height)
    }

    addLabel(at: centroid)
  }

  private func buildPolygonMesh(_ boundary: [ARBoundaryPoint], width: Float, height: Float)
    -> SIMD3<Float>
  {
    let localPoints: [SIMD3<Float>] = boundary.map { pt in
      SIMD3<Float>((Float(pt.x) - 0.5) * width, 0, (Float(pt.y) - 0.5) * height)
    }

    do {
      let mesh = try PolygonTriangulator.makeFieldMesh(boundary: localPoints)
      applyMesh(mesh)
    } catch {
      #if DEBUG
        print("❌ Triangulation failed for \(zone.name): \(error)")
      #endif
      if let rect = zone.arPosition {
        return buildRectangleMesh(rect, width: width, height: height)
      }
    }

    return polygonCentroid(localPoints)
  }

  /// True area-weighted polygon centroid (the "center of mass" of the
  /// shape), not just an average of its vertices — this places the label
  /// visually in the middle of an irregular shape, rather than skewed
  /// toward wherever the boundary happens to have more points clustered.
  private func polygonCentroid(_ points: [SIMD3<Float>]) -> SIMD3<Float> {
    var area: Float = 0
    var cx: Float = 0
    var cz: Float = 0

    let n = points.count
    for i in 0..<n {
      let p0 = points[i]
      let p1 = points[(i + 1) % n]
      let cross = p0.x * p1.z - p1.x * p0.z
      area += cross
      cx += (p0.x + p1.x) * cross
      cz += (p0.z + p1.z) * cross
    }

    area *= 0.5

    guard abs(area) > 0.000001 else {
      // Degenerate polygon fallback — simple average.
      let avgX = points.map { $0.x }.reduce(0, +) / Float(n)
      let avgZ = points.map { $0.z }.reduce(0, +) / Float(n)
      return SIMD3<Float>(avgX, 0, avgZ)
    }

    cx /= (6 * area)
    cz /= (6 * area)

    return SIMD3<Float>(cx, 0, cz)
  }

  @discardableResult
  private func buildRectangleMesh(_ rect: ARPosition, width: Float, height: Float) -> SIMD3<Float> {
    let mesh = MeshResource.generatePlane(width: rect.width * width, depth: rect.height * height)
    applyMesh(mesh)
    let position = SIMD3<Float>((rect.x - 0.5) * width, 0, (rect.y - 0.5) * height)
    modelEntity?.position = position
    return position
  }

  private func applyMesh(_ mesh: MeshResource) {
    var material = UnlitMaterial(color: colorForStatus())
    material.faceCulling = .none
    material.blending = .transparent(opacity: .init(floatLiteral: 1.0))

    let model = ModelEntity(mesh: mesh, materials: [material])
    model.name = zone.name
    model.generateCollisionShapes(recursive: true)
    addChild(model)
    modelEntity = model
  }

  /// Renders a styled label card (badge + name + underline + status),
  /// as a texture on a billboarded plane, parented to this ZoneEntity so
  /// it stays locked to the map anchor along with the shape itself.
  private func addLabel(at centroid: SIMD3<Float>) {
    guard
      let cgImage = LabelCardRenderer.render(
        badgeText: zone.id,
        title: zone.name,
        status: zone.status.rawValue,
        statusColor: colorForStatus()
      )
    else { return }

    do {
      let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))

      var material = UnlitMaterial()
      material.color = .init(tint: .white, texture: .init(texture))
      material.faceCulling = .none
      material.blending = .transparent(opacity: .init(floatLiteral: 1.0))

      // Bumped up from 0.06 -> 0.09 for larger, more legible text.
      let labelWidth: Float = 0.09
      let aspect = Float(cgImage.height) / Float(cgImage.width)
      let labelHeight = labelWidth * aspect

      let mesh = MeshResource.generatePlane(width: labelWidth, height: labelHeight)
      let label = ModelEntity(mesh: mesh, materials: [material])

      label.position = SIMD3<Float>(centroid.x, 0.02, centroid.z)
      label.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
      label.components.set(BillboardComponent())

      addChild(label)
      labelEntity = label
    } catch {
      #if DEBUG
        print("❌ Failed to build label texture for \(zone.name): \(error)")
      #endif
    }
  }

  func updateStatus(_ newStatus: ZoneStatus) {
    guard let model = modelEntity else { return }
    var material = UnlitMaterial()
    material.color = .init(tint: colorForStatus(newStatus))
    material.faceCulling = .none
    material.blending = .transparent(opacity: .init(floatLiteral: 1.0))
    model.model?.materials = [material]
  }

  private func colorForStatus(_ status: ZoneStatus? = nil) -> UIColor {
    switch status ?? zone.status {
    case .healthy:
      return UIColor(red: 0.20, green: 0.65, blue: 0.20, alpha: 0.55)
    case .warning:
      return UIColor(red: 0.85, green: 0.70, blue: 0.10, alpha: 0.55)
    case .critical:
      return UIColor(red: 0.80, green: 0.30, blue: 0.10, alpha: 0.55)
    }
  }
}
