import UIKit

extension UIImage {
    func resized(toSize targetSize: CGSize) -> UIImage? {
        let imageSize = self.size
        let widthRatio = targetSize.width / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * scaleFactor
        let scaledHeight = imageSize.height * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: scaledWidth, height: scaledHeight), false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return resizedImage
    }
}

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }
}

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 0.0)?.base64EncodedString()
    }
}
