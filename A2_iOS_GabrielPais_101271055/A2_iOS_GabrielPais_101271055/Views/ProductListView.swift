import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: false)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    var searchText: String
    
    // Filter products by name or description
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return Array(products)
        } else {
            return products.filter { product in
                let nameMatch = product.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let descriptionMatch = product.productDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || descriptionMatch
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredProducts, id: \.self) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    HStack {
                        // Show thumbnail image if available
                        if product.hasImage, let id = product.productID {
                            ProductThumbnailView(productID: id)
                                .frame(width: 50, height: 50)
                                .cornerRadius(6)
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(product.name ?? "Unknown")
                                .font(.headline)
                            Text(product.productDescription ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        // Add this to ensure content doesn't go under the tab bar
        .edgesIgnoringSafeArea([.horizontal, .top])
        .safeAreaInset(edge: .bottom) {
            // Add empty space at the bottom to prevent overlap with tab bar
            Color.clear.frame(height: 1)
        }
    }
}

// A new view to efficiently load product thumbnails
struct ProductThumbnailView: View {
    var productID: UUID
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let productImagesURL = documentsURL.appendingPathComponent("ProductImages").appendingPathComponent(productID.uuidString)
            
            do {
                if fileManager.fileExists(atPath: productImagesURL.path) {
                    let fileURLs = try fileManager.contentsOfDirectory(at: productImagesURL, includingPropertiesForKeys: nil)
                    
                    for fileURL in fileURLs where fileURL.pathExtension.lowercased() == "jpg" {
                        if let data = try? Data(contentsOf: fileURL),
                           let loadedImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.image = loadedImage
                            }
                            break // Only need the first image
                        }
                    }
                }
            } catch {
                print("Error loading thumbnail for product \(productID): \(error)")
            }
        }
    }
}
