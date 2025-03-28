//
//  Product_CoreDataProperties.swift
//  A2_iOS_GabrielPais_101271055
//
//  Created by viorel pais on 2025-03-28.
//

import Foundation
import CoreData

extension Product {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var productID: UUID?
    @NSManaged public var name: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var price: Double
    @NSManaged public var provider: String?
}

extension Product : Identifiable {

}
