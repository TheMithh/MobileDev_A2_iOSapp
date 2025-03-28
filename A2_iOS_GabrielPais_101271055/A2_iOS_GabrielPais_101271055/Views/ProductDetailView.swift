import SwiftUI
import CoreData

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
                    .padding(.vertical, 1)
                Text("Price: $\(product.price, specifier: "%.2f")")
                    .padding(.vertical, 1)
                
                Text(product.productDescription ?? "")
                    .padding(.vertical, 2)
                
                if product.hasImage {
                    ProductImagesView(productID: product.productID)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea([.horizontal])
    }
}
