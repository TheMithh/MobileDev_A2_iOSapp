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
                Button(action: {
                    isShowingImagePicker = true
                }) {
                    HStack {
                        Text("Select Image")
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
        newProduct.hasImage = selectedImage != nil
        
        do {
            try viewContext.save()
            
            // Save the image if one is selected
            if let image = selectedImage, let id = newProduct.productID {
                saveImage(image, forProductID: id)
            }
            
            // Reset form fields
            name = ""
            description = ""
            price = ""
            provider = ""
            selectedImage = nil
            
            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving product: \(error)")
        }
    }
    
    func saveImage(_ image: UIImage, forProductID id: UUID) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let productImagesURL = documentsURL.appendingPathComponent("ProductImages").appendingPathComponent(id.uuidString)
            
            do {
                // Create directories if they don't exist
                try fileManager.createDirectory(at: productImagesURL, withIntermediateDirectories: true)
                
                // Save the image
                let fileURL = productImagesURL.appendingPathComponent("image_1.jpg")
                try data.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
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
