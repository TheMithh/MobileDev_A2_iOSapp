import SwiftUI

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields for the new product
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var provider: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Provider", text: $provider)
            }
            
            Button(action: addProduct) {
                Text("Add Product")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
    
    func addProduct() {
        let newProduct = Product(context: viewContext)
        newProduct.productID = UUID()
        newProduct.name = name
        newProduct.productDescription = description
        newProduct.price = Double(price) ?? 0.0
        newProduct.provider = provider
        
        do {
            try viewContext.save()
            
            // Reset form fields
            name = ""
            description = ""
            price = ""
            provider = ""
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving product: \(error)")
        }
    }
}
