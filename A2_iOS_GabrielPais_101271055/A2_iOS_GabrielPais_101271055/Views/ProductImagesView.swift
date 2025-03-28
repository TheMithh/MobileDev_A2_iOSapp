import SwiftUI

struct ProductImagesView: View {
    var productID: UUID?
    @State private var images: [UIImage] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            if !images.isEmpty {
                Text("Product Images")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else {
                Text("No product images available")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.vertical, 8)
            }
        }
        .onAppear {
            loadImages()
        }
    }
    
    func loadImages() {
        guard let id = productID else { return }
        let fileManager = FileManager.default
        
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let productImagesURL = documentsURL.appendingPathComponent("ProductImages").appendingPathComponent(id.uuidString)
            
            do {
                if fileManager.fileExists(atPath: productImagesURL.path) {
                    let fileURLs = try fileManager.contentsOfDirectory(at: productImagesURL, includingPropertiesForKeys: nil)
                    var loadedImages: [UIImage] = []
                    
                    for fileURL in fileURLs where fileURL.pathExtension.lowercased() == "jpg" {
                        if let data = try? Data(contentsOf: fileURL),
                           let image = UIImage(data: data) {
                            loadedImages.append(image)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.images = loadedImages
                    }
                }
            } catch {
                print("Error loading images for product \(id): \(error)")
            }
        }
    }
}
