import SwiftUI

struct ProductImagesView: View {
    var productID: UUID?
    @State private var images: [UIImage] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            loadImages()
        }
    }
    
    func loadImages() {
        guard let id = productID else { return }
        let fileManager = FileManager.default
        // Assumes images are stored in Documents/ProductImages/<productID>/
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let productImagesURL = documentsURL.appendingPathComponent("ProductImages").appendingPathComponent(id.uuidString)
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: productImagesURL, includingPropertiesForKeys: nil)
                var loadedImages: [UIImage] = []
                for fileURL in fileURLs {
                    if let data = try? Data(contentsOf: fileURL),
                       let image = UIImage(data: data) {
                        loadedImages.append(image)
                    }
                }
                self.images = loadedImages
            } catch {
                print("Error loading images for product \(id): \(error)")
            }
        }
    }
}
