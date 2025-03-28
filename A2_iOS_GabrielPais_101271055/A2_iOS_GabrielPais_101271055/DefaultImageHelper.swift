import Foundation
import UIKit

/// Helper class for managing default product images
class DefaultImageHelper {
    static let shared = DefaultImageHelper()
    
    private let defaultImageCount = 5
    
    /// Gets a default image either from the bundle or a random one
    func getDefaultImage(index: Int? = nil) -> UIImage? {
        // If index is specified, try to get that specific default image
        if let index = index {
            let imageName = "product_default_\(index % defaultImageCount + 1)"
            return UIImage(named: imageName)
        }
        
        // Otherwise, get a random default image
        let randomIndex = Int.random(in: 1...defaultImageCount)
        return UIImage(named: "product_default_\(randomIndex)")
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
