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
    
    // In ProductListView.swift, update the body property:
    var body: some View {
        List {
            ForEach(filteredProducts, id: \.self) { product in
                VStack(alignment: .leading) {
                    Text(product.name ?? "Unknown")
                        .font(.headline)
                    Text(product.productDescription ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        }
    }

