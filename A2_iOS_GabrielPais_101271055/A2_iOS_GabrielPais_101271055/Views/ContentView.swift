import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch all products sorted by name (you can change the sort criteria as needed)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    @State private var currentIndex = 0
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            // Detail View Tab
            VStack {
                if !products.isEmpty {
                    ProductDetailView(product: products[currentIndex])
                    HStack {
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }) {
                            Text("Previous")
                        }
                        Spacer()
                        Button(action: {
                            if currentIndex < products.count - 1 {
                                currentIndex += 1
                            }
                        }) {
                            Text("Next")
                        }
                    }
                    .padding()
                } else {
                    Text("No Products Available")
                        .padding()
                }
            }
            .tabItem {
                Image(systemName: "doc.text")
                Text("Detail")
            }
            
            // List View Tab with Search
            NavigationView {
                VStack {
                    SearchBar(text: $searchText)
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
        }
        do {
            try viewContext.save()
        } catch {
            print("Error saving sample products: \(error)")
        }
    }
}
