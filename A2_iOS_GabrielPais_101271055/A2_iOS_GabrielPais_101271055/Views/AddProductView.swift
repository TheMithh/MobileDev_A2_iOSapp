import SwiftUI

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields for the new product
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var provider: String = ""
    
    // Form validation
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Product Details").font(.headline)) {
                VStack(alignment: .leading) {
                    Text("Product Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Enter product name", text: $name)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(5)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Price ($)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("0.00", text: $price)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Provider")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Enter provider name", text: $provider)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Button(action: validateAndAddProduct) {
                    HStack {
                        Spacer()
                        Text("Add Product")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Add New Product")
        .alert(isPresented: $showingValidationAlert) {
            Alert(
                title: Text("Invalid Input"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func validateAndAddProduct() {
        // Basic validation
        if name.isEmpty {
            validationMessage = "Please enter a product name."
            showingValidationAlert = true
            return
        }
        
        if price.isEmpty {
            validationMessage = "Please enter a price."
            showingValidationAlert = true
            return
        }
        
        guard let priceValue = Double(price) else {
            validationMessage = "Price must be a valid number."
            showingValidationAlert = true
            return
        }
        
        if priceValue < 0 {
            validationMessage = "Price cannot be negative."
            showingValidationAlert = true
            return
        }
        
        // All validation passed, add the product
        addProduct()
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
