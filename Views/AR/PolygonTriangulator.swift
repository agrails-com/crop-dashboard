import RealityKit
import simd

/// Converts a flat, simple (non-self-intersecting) polygon into a triangulated
/// RealityKit mesh using ear-clipping. Sufficient for concave, non-intersecting
/// agricultural field boundaries.
enum PolygonTriangulator {

  enum TriangulationError: Error {
    case tooFewPoints
    case degeneratePolygon
  }

  /// boundary: ordered points on the XZ plane (Y is up in RealityKit).
  static func makeFieldMesh(boundary: [SIMD3<Float>]) throws -> MeshResource {
    guard boundary.count >= 3 else {
      throw TriangulationError.tooFewPoints
    }

    let indices = try triangulate(boundary)

    var descriptor = MeshDescriptor(name: "fieldZone")
    descriptor.positions = MeshBuffer(boundary)
    descriptor.normals = MeshBuffer(Array(repeating: SIMD3<Float>(0, 1, 0), count: boundary.count))
    descriptor.primitives = .triangles(indices)

    return try MeshResource.generate(from: [descriptor])
  }

  private static func triangulate(_ points: [SIMD3<Float>]) throws -> [UInt32] {
    var indices = Array(0..<points.count)
    var triangles: [UInt32] = []

    if signedArea(points, indices: indices) < 0 {
      indices.reverse()
    }

    var guardCounter = 0
    let maxIterations = points.count * points.count

    while indices.count > 3 {
      guardCounter += 1
      if guardCounter > maxIterations {
        throw TriangulationError.degeneratePolygon
      }

      var earFound = false

      for i in 0..<indices.count {
        let prevIdx = indices[(i + indices.count - 1) % indices.count]
        let currIdx = indices[i]
        let nextIdx = indices[(i + 1) % indices.count]

        let a = points[prevIdx]
        let b = points[currIdx]
        let c = points[nextIdx]

        if !isConvex(a, b, c) { continue }

        var containsOther = false
        for j in indices where j != prevIdx && j != currIdx && j != nextIdx {
          if pointInTriangle(points[j], a, b, c) {
            containsOther = true
            break
          }
        }
        if containsOther { continue }

        triangles.append(UInt32(prevIdx))
        triangles.append(UInt32(currIdx))
        triangles.append(UInt32(nextIdx))
        indices.remove(at: i)
        earFound = true
        break
      }

      if !earFound {
        throw TriangulationError.degeneratePolygon
      }
    }

    if indices.count == 3 {
      triangles.append(UInt32(indices[0]))
      triangles.append(UInt32(indices[1]))
      triangles.append(UInt32(indices[2]))
    }

    return triangles
  }

  private static func signedArea(_ points: [SIMD3<Float>], indices: [Int]) -> Float {
    var sum: Float = 0
    for i in 0..<indices.count {
      let p1 = points[indices[i]]
      let p2 = points[indices[(i + 1) % indices.count]]
      sum += (p1.x * p2.z - p2.x * p1.z)
    }
    return sum * 0.5
  }

  private static func isConvex(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>) -> Bool {
    let cross = (b.x - a.x) * (c.z - a.z) - (b.z - a.z) * (c.x - a.x)
    return cross > 0
  }

  private static func pointInTriangle(
    _ p: SIMD3<Float>, _ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>
  ) -> Bool {
    func sign(_ p1: SIMD3<Float>, _ p2: SIMD3<Float>, _ p3: SIMD3<Float>) -> Float {
      (p1.x - p3.x) * (p2.z - p3.z) - (p2.x - p3.x) * (p1.z - p3.z)
    }
    let d1 = sign(p, a, b)
    let d2 = sign(p, b, c)
    let d3 = sign(p, c, a)
    let hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0)
    let hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0)
    return !(hasNeg && hasPos)
  }
}
