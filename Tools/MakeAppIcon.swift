import AppKit

// Original vector drawing for the app; no external icon artwork or bundled fonts.
@main struct MakeAppIcon {
    static func main() throws {
        let assets = URL(fileURLWithPath: CommandLine.arguments[1])
        let iconset = assets.appendingPathComponent("AppIcon.iconset", isDirectory: true)
        try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
        for (name, pixels) in [
            ("icon_16x16", 16), ("icon_16x16@2x", 32),
            ("icon_32x32", 32), ("icon_32x32@2x", 64),
            ("icon_128x128", 128), ("icon_128x128@2x", 256),
            ("icon_256x256", 256), ("icon_256x256@2x", 512),
            ("icon_512x512", 512), ("icon_512x512@2x", 1024)
        ] {
            let png = render(pixels: pixels)
            try png.write(to: iconset.appendingPathComponent(name + ".png"))
            if pixels == 1024 { try png.write(to: assets.appendingPathComponent("AppIcon.png")) }
        }
        // Standard ICNS container with PNG representations, including Retina sizes.
        var chunks = Data()
        for (type, name) in [
            ("icp4", "icon_16x16"), ("icp5", "icon_32x32"), ("icp6", "icon_32x32@2x"),
            ("ic07", "icon_128x128"), ("ic08", "icon_256x256"), ("ic09", "icon_512x512"),
            ("ic10", "icon_512x512@2x"), ("ic11", "icon_16x16@2x"), ("ic12", "icon_32x32@2x"),
            ("ic13", "icon_128x128@2x"), ("ic14", "icon_256x256@2x")
        ] {
            let png = try Data(contentsOf: iconset.appendingPathComponent(name + ".png"))
            chunks.append(Data(type.utf8)); chunks.append(lengthBytes(png.count + 8)); chunks.append(png)
        }
        var icns = Data("icns".utf8); icns.append(lengthBytes(chunks.count + 8)); icns.append(chunks)
        try icns.write(to: assets.appendingPathComponent("AppIcon.icns"))
        guard NSImage(contentsOf: assets.appendingPathComponent("AppIcon.icns")) != nil else {
            fatalError("Generated icon could not be read by AppKit")
        }
    }
    static func lengthBytes(_ value: Int) -> Data {
        var bigEndian = UInt32(value).bigEndian
        return withUnsafeBytes(of: &bigEndian) { Data($0) }
    }
    static func render(pixels: Int) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = NSSize(width: pixels, height: pixels)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let transform = AffineTransform(scale: CGFloat(pixels) / 1024)
        (transform as NSAffineTransform).concat()
        NSColor.clear.setFill(); NSRect(x: 0, y: 0, width: 1024, height: 1024).fill()
        let tile = NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896), xRadius: 200, yRadius: 200)
        NSGradient(starting: NSColor(red: 0.07, green: 0.32, blue: 0.36, alpha: 1),
                   ending: NSColor(red: 0.06, green: 0.56, blue: 0.52, alpha: 1))!.draw(in: tile, angle: 45)
        let inset = NSBezierPath(roundedRect: NSRect(x: 80, y: 80, width: 864, height: 864), xRadius: 185, yRadius: 185)
        NSColor.white.withAlphaComponent(0.12).setStroke(); inset.lineWidth = 2; inset.stroke()
        let cream = NSColor(red: 1, green: 0.97, blue: 0.88, alpha: 1)
        let font = NSFont(name: "PingFangTC-Semibold", size: 510) ?? NSFont.systemFont(ofSize: 510, weight: .semibold)
        let word = NSAttributedString(string: "拼", attributes: [.font: font, .foregroundColor: cream])
        let size = word.size()
        word.draw(at: NSPoint(x: (1024 - size.width) / 2, y: 230))
        let label = NSAttributedString(string: "ping3 jam1", attributes: [.font: NSFont.systemFont(ofSize: 68, weight: .medium), .kern: 2.5, .foregroundColor: cream.withAlphaComponent(0.86)])
        label.draw(at: NSPoint(x: (1024 - label.size().width) / 2 + 1.25, y: 190))
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])!
    }
}
