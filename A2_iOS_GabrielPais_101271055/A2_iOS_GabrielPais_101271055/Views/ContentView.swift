import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("selectedTab") private var selectedTab = 0

    // Fetch all products sorted by name
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var currentIndex = 0
    @State private var searchText = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Detail View Tab
            NavigationView {
                ZStack {
                    // Background color
                    Color(.systemBackground).edgesIgnoringSafeArea(.all)
                    
                    if !products.isEmpty {
                        // Ensure currentIndex is valid
                        let safeIndex = min(currentIndex, products.count - 1)
                        
                        VStack {
                            ProductDetailView(product: products[safeIndex])
                            
                            // Navigation controls with improved styling
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation {
                                        if currentIndex > 0 {
                                            currentIndex -= 1
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Previous")
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(currentIndex > 0 ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(currentIndex > 0 ? .white : .gray)
                                    .cornerRadius(8)
                                }
                                .disabled(currentIndex <= 0)
                                
                                Spacer()
                                
                                // Counter display
                                Text("\(currentIndex + 1) of \(products.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        if currentIndex < products.count - 1 {
                                            currentIndex += 1
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(currentIndex < products.count - 1 ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(currentIndex < products.count - 1 ? .white : .gray)
                                    .cornerRadius(8)
                                }
                                .disabled(currentIndex >= products.count - 1)
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "cart.badge.questionmark")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)
                            
                            Text("No Products Available")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Text("Add some products to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                selectedTab = 2 // Switch to Add tab
                            }) {
                                Text("Add Product")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                    }
                }
                .navigationTitle("Product Details")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Detail")
            }
            .tag(0)
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
                    // Improved Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    // Show either the product list or empty state
                    if filteredProducts.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text(searchText.isEmpty ? "No Products Available" : "No Matching Products")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            if searchText.isEmpty {
                                Button(action: {
                                    selectedTab = 2 // Switch to Add tab
                                }) {
                                    Text("Add Your First Product")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            } else {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Text("Clear Search")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    } else {
                        ProductListView(searchText: searchText)
                    }
                }
                .navigationTitle("Product Catalog")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "list.bullet.fill")
                Text("List")
            }
            .tag(1)
            
            // Add Product Tab
            NavigationView {
                AddProductView()
                  .navigationTitle("Add Product")
                  .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Add")
            }
            .tag(2)
        }
        .onAppear {
            // Force dark text on light status bar for better readability
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
            
            // Pre-populate sample data if no products exist
            if products.isEmpty {
                addSampleProducts()
            }
        }
        .accentColor(.blue) // Set accent color for the entire app
    }
    
    // Computed property for filtered products (used in empty state logic)
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
    
    private func addSampleProducts() {
        // Sample product data with more realistic values
        let sampleData: [(name: String, desc: String, price: Double, provider: String)] = [
            ("MacBook Pro 16\"", "Powerful laptop with M2 Max chip, 32GB RAM, and 1TB SSD.", 2499.99, "Apple Inc."),
            ("Wireless Earbuds", "Noise-cancelling earbuds with 24-hour battery life.", 129.99, "Sony Electronics"),
            ("Office Chair", "Ergonomic chair with lumbar support and adjustable height.", 249.95, "Herman Miller"),
            ("Smart TV 65\"", "4K OLED TV with HDR and smart features.", 1299.99, "Samsung Electronics"),
            ("Fitness Tracker", "Tracks steps, heart rate, and sleep patterns.", 89.99, "Fitbit"),
            ("Coffee Maker", "Programmable coffee maker with thermal carafe.", 149.95, "Breville"),
            ("Wireless Mouse", "Ergonomic wireless mouse with long battery life.", 59.99, "Logitech"),
            ("Portable SSD 1TB", "High-speed external solid state drive.", 179.95, "Western Digital"),
            ("Smart Speaker", "Voice-controlled speaker with virtual assistant.", 99.99, "Amazon"),
            ("Digital Camera", "24MP mirrorless camera with 4K video capability.", 899.99, "Canon")
        ]
        
        // Create sample products
        for productData in sampleData {
            let newProduct = Product(context: viewContext)
            newProduct.productID = UUID()
            newProduct.name = productData.name
            newProduct.productDescription = productData.desc
            newProduct.price = productData.price
            newProduct.provider = productData.provider
        }
        
        do {
            try viewContext.save()
            print("Successfully added sample products")
        } catch {
            print("Error saving sample products: \(error)")
        }
    }
}
