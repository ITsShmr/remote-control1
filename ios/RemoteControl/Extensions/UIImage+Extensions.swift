import UIKit

extension UIImage {
    func compressedJPEG(quality: CGFloat = 0.8) -> Data? {
        autoreleasepool {
            jpegData(compressionQuality: quality)
        }
    }

    func scaledTo(factor: CGFloat) -> UIImage? {
        let size = CGSize(width: self.size.width * factor,
                         height: self.size.height * factor)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
