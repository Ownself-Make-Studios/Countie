import SwiftUI
import UIKit

extension UIImage {
    // Render an emoji as an image
    static func image(from emoji: String, size: CGFloat = 64) -> UIImage? {
        let size = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size.width * 0.8)
        ]
        let textSize = emoji.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        emoji.draw(in: textRect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // Extract the dominant color from the image
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        let width = 1
        let height = 1
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: 4)
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let r = CGFloat(pixelData[0]) / 255.0
        let g = CGFloat(pixelData[1]) / 255.0
        let b = CGFloat(pixelData[2]) / 255.0
        let a = CGFloat(pixelData[3]) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIColor {
    func vibrant(saturationMultiplier: CGFloat = 0.5, brightnessMultiplier: CGFloat = 1.8) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newSaturation = min(saturation * saturationMultiplier, 1.0)
            let newBrightness = min(brightness * brightnessMultiplier, 1.0)
            return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: alpha)
        }
        return self
    }
}

extension Color {
    init?(dominantColorOf emoji: String) {
        guard let image = UIImage.image(from: emoji),
              let uiColor = image.dominantColor() else {
            return nil
        }
        self.init(uiColor)
    }
    
    init?(vibrantDominantColorOf emoji: String) {
        guard let image = UIImage.image(from: emoji),
              let uiColor = image.dominantColor()?.vibrant() else {
            return nil
        }
        self.init(uiColor)
    }
}
