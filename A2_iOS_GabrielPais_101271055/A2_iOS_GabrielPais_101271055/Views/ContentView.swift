import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch all products sorted by name (you can change the sort criteria as needed)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.productID, ascending: false)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var currentIndex = 0
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            // Detail View Tab
            NavigationView {
                VStack {
                    if !products.isEmpty {
                        // Ensure currentIndex is valid
                        let safeIndex = min(currentIndex, products.count - 1)
                        
                        ProductDetailView(product: products[safeIndex])
                        HStack {
                            Button(action: {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }) {
                                Text("Previous")
                                    .disabled(currentIndex <= 0)
                            }
                            Spacer()
                            Button(action: {
                                if currentIndex < products.count - 1 {
                                    currentIndex += 1
                                }
                            }) {
                                Text("Next")
                                    .disabled(currentIndex >= products.count - 1)
                            }
                        }
                        .padding()
                    } else {
                        Text("No Products Available")
                            .padding()
                    }
                }
                .navigationTitle("Product Details")
            }
            .tabItem {
                Image(systemName: "doc.text")
                Text("Detail")
            }
            .onChange(of: products.count) { newCount in
                // If products count changes, ensure currentIndex is valid
                if newCount == 0 {
                    currentIndex = 0
                } else if currentIndex >= newCount {
                    currentIndex = newCount - 1
                }
            }
            
            // List View Tab with Search
            NavigationView {
                VStack(spacing: 0) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    ProductListView(searchText: searchText)
                }
                .navigationTitle("Products")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("List")
            }
            
            // Add Product Tab
            NavigationView {
                AddProductView()
                  .navigationTitle("Add Product")
            }
            .tabItem {
                Image(systemName: "plus.circle")
                Text("Add")
            }
        }
        .onAppear {
            // Pre-populate sample data if no products exist
            if products.isEmpty {
                addSampleProducts()
            }
        }
    }
    
    private func addSampleProducts() {
        for i in 1...10 {
            let newProduct = Product(context: viewContext)
            newProduct.productID = UUID()
            newProduct.name = "Product \(i)"
            newProduct.productDescription = "This is the description for product \(i)."
            newProduct.price = Double(i) * 10.0
            newProduct.provider = "Provider \(i)"
            newProduct.hasImage = true  // Set to true as we'll assign default images
        }
        
        do {
            try viewContext.save()
            
            // Now assign default images to each sample product
            for (index, product) in products.enumerated() {
                if let id = product.productID {
                    // Use the index to assign different default images to each product
                    DefaultImageHelper.shared.saveDefaultImageForProduct(productID: id, index: index)
                }
            }
        } catch {
            print("Error saving sample products: \(error)")
        }
    }
}
