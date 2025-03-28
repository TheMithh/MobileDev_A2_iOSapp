import SwiftUI
import PhotosUI

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields for the new product
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var provider: String = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var useDefaultImage = true // Default to true
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Provider", text: $provider)
            }
            
            Section(header: Text("Product Image")) {
                Toggle("Use Default Image", isOn: $useDefaultImage)
                
                if !useDefaultImage {
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Text("Select Custom Image")
                            Spacer()
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("Using Default Image")
                        Spacer()
                        // Show a random default image preview
                        if let defaultImage = DefaultImageHelper.shared.getDefaultImage() {
                            Image(uiImage: defaultImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        }
                    }
                }
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
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    func addProduct() {
        let newProduct = Product(context: viewContext)
        newProduct.productID = UUID()
        newProduct.name = name
        newProduct.productDescription = description
        newProduct.price = Double(price) ?? 0.0
        newProduct.provider = provider
        
        // Set hasImage to true always - either custom or default
        newProduct.hasImage = true
        
        do {
            try viewContext.save()
            
            if let id = newProduct.productID {
                if useDefaultImage {
                    // Use default image
                    DefaultImageHelper.shared.saveDefaultImageForProduct(productID: id)
                } else if let image = selectedImage {
                    // Use selected custom image
                    DefaultImageHelper.shared.saveImage(image, forProductID: id)
                } else {
                    // No image selected but not using default - still use a default
                    DefaultImageHelper.shared.saveDefaultImageForProduct(productID: id)
                }
            }
            
            // Reset form fields
            name = ""
            description = ""
            price = ""
            provider = ""
            selectedImage = nil
            useDefaultImage = true
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving product: \(error)")
        }
    }
}

// Image Picker struct
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
