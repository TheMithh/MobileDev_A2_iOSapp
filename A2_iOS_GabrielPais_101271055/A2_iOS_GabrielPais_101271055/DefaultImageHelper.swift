import Foundation
import UIKit

/// Helper class for managing default product images
class DefaultImageHelper {
    static let shared = DefaultImageHelper()
    
    // We have 10 default images named product_default_1 through product_default_10
    // And one special default image named product_default_0
    private let defaultImageCount = 10
    private let defaultFallbackImage = "product_default_0" // The 11th image used as ultimate fallback
    
    /// Gets a default image either from the bundle or a random one
    func getDefaultImage(index: Int? = nil) -> UIImage? {
        // If index is specified, try to get that specific default image
        if let index = index {
            let imageIndex = (index % defaultImageCount) + 1 // 1-based indexing to match asset names
            let imageName = "product_default_\(imageIndex)"
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        // If index-based lookup failed or no index specified, get a random default image
        let randomIndex = Int.random(in: 1...defaultImageCount)
        if let image = UIImage(named: "product_default_\(randomIndex)") {
            return image
        }
        
        // If all else fails, use the special default fallback image
        return UIImage(named: defaultFallbackImage)
    }
    
    /// Save a default image for a product
    func saveDefaultImageForProduct(productID: UUID, index: Int? = nil) {
        // Get a default image
        guard let image = getDefaultImage(index: index) else { return }
        
        // Save it to the product's directory
        saveImage(image, forProductID: productID)
    }
    
    /// Saves an image to the product's directory
    func saveImage(_ image: UIImage, forProductID id: UUID) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let productImagesURL = documentsURL.appendingPathComponent("ProductImages").appendingPathComponent(id.uuidString)
            
            do {
                // Create directories if they don't exist
                try fileManager.createDirectory(at: productImagesURL, withIntermediateDirectories: true, attributes: nil)
                
                // Save the image
                let fileURL = productImagesURL.appendingPathComponent("image_1.jpg")
                try data.write(to: fileURL)
                print("Saved default image for product \(id.uuidString)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}
