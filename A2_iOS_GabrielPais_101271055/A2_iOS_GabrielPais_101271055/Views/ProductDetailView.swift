import SwiftUI
import CoreData

struct ProductDetailView: View {
    var product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Name with Styling
                Text(product.name ?? "Unknown Product")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                
                // Product ID with subtle styling
                HStack {
                    Text("Product ID:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(product.productID?.uuidString.prefix(8) ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                .padding(.bottom, 8)
                
                // Price Card
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Price")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("$\(product.price, specifier: "%.2f")")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Provider")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(product.provider ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                }
                .frame(height: 100)
                
                // Description Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(product.productDescription ?? "No description available.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
