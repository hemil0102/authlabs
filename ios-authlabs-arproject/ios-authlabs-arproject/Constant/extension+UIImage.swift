
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
