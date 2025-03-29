import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
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
        // Fixed the bug with the list overshadowing the tab bar menu
        List {
            ForEach(filteredProducts, id: \.self) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    HStack {
                        // Product icon
                        ZStack {
                            Circle()
                                .fill(colorForProduct(product))
                                .frame(width: 40, height: 40)
                            
                            Text(String(product.name?.prefix(1) ?? "?"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                                
                                Text("•")
                                    .foregroundColor(.gray)
                                
                                Text(product.provider ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        // Fix for the menu list overshadowing issue
        .listStyle(InsetGroupedListStyle())
        .padding(.bottom, 0)
        // Use safeAreaInset instead of ignoring safe area edges to prevent overshadowing
        .safeAreaInset(edge: .bottom) {
            // Add enough space for the tab bar
            Color.clear.frame(height: 49)
        }
    }
    
    // Generate consistent color based on product name
    private func colorForProduct(_ product: Product) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink,
            .red, .teal, .indigo, .mint, .cyan
        ]
        
        // Use the product name or ID to create a consistent color
        let nameHash = (product.name ?? "Unknown").hash
        let index = abs(nameHash) % colors.count
        
        return colors[index]
    }
}
