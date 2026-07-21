import UIKit

/// Renders a styled zone label (badge + title + underline + status text),
/// matching the printed map's card design, as a transparent-background image
/// suitable for use as an AR billboard texture.
enum LabelCardRenderer {

  static func render(badgeText: String, title: String, status: String, statusColor: UIColor)
    -> CGImage?
  {
    let size = CGSize(width: 600, height: 280)

    let format = UIGraphicsImageRendererFormat()
    format.opaque = false
    format.scale = 3  // crisp text when scaled up on the AR plane

    let renderer = UIGraphicsImageRenderer(size: size, format: format)

    let image = renderer.image { ctx in
      let cg = ctx.cgContext
      let centerX = size.width / 2

      // Badge (rounded square with "Z1" / "Z2" / "Z3")
      let badgeSize = CGSize(width: 100, height: 100)
      let badgeRect = CGRect(
        x: centerX - badgeSize.width / 2,
        y: 0,
        width: badgeSize.width,
        height: badgeSize.height
      )
      let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 20)
      statusColor.withAlphaComponent(1.0).setFill()
      badgePath.fill()

      drawCentered(
        text: badgeText,
        in: badgeRect,
        font: .boldSystemFont(ofSize: 44),
        color: .white,
        context: cg
      )

      // Title (field name), bold, white, with a drop shadow for
      // legibility against varying map backgrounds.
      let titleRect = CGRect(x: 0, y: badgeRect.maxY + 16, width: size.width, height: 70)
      drawCentered(
        text: title.uppercased(),
        in: titleRect,
        font: .boldSystemFont(ofSize: 52),
        color: .white,
        context: cg,
        shadow: true
      )

      // Underline beneath the title
      let underlineWidth: CGFloat = 260
      let underlineY = titleRect.maxY - 6
      cg.setStrokeColor(UIColor.white.cgColor)
      cg.setLineWidth(3)
      cg.move(to: CGPoint(x: centerX - underlineWidth / 2, y: underlineY))
      cg.addLine(to: CGPoint(x: centerX + underlineWidth / 2, y: underlineY))
      cg.strokePath()

      // Status word, colored, bold, all caps
      let statusRect = CGRect(x: 0, y: underlineY + 14, width: size.width, height: 60)
      drawCentered(
        text: status.uppercased(),
        in: statusRect,
        font: .boldSystemFont(ofSize: 40),
        color: statusColor,
        context: cg,
        shadow: true
      )
    }

    return image.cgImage
  }

  private static func drawCentered(
    text: String,
    in rect: CGRect,
    font: UIFont,
    color: UIColor,
    context: CGContext,
    shadow: Bool = false
  ) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    var attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph,
    ]

    if shadow {
      let shadowObj = NSShadow()
      shadowObj.shadowColor = UIColor.black.withAlphaComponent(0.6)
      shadowObj.shadowOffset = CGSize(width: 0, height: 2)
      shadowObj.shadowBlurRadius = 4
      attributes[.shadow] = shadowObj
    }

    let attributed = NSAttributedString(string: text, attributes: attributes)
    let textSize = attributed.size()
    let drawRect = CGRect(
      x: rect.minX,
      y: rect.minY + (rect.height - textSize.height) / 2,
      width: rect.width,
      height: textSize.height
    )
    attributed.draw(in: drawRect)
  }
}
