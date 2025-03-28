import SwiftUI

struct ProductDetailView: View {
    var product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name ?? "Unknown Product")
                    .font(.title)
                    .padding(.bottom, 2)
                Text("ID: \(product.productID?.uuidString ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Provider: \(product.provider ?? "")")
                Text("Price: $\(product.price, specifier: "%.2f")")
                Text(product.productDescription ?? "")
                    .padding(.vertical, 2)
                
                // Product images loaded from file system
                ProductImagesView(productID: product.productID)
            }
            .padding()
        }
    }
}
