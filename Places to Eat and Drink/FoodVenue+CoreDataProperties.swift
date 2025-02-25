//
//  FoodVenue+CoreDataProperties.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 05/12/2024.
//
//

import Foundation
import CoreData


extension FoodVenue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodVenue> {
        return NSFetchRequest<FoodVenue>(entityName: "FoodVenue")
    }

    @NSManaged public var amenitiesString: String?
    @NSManaged public var building: String?
    @NSManaged public var desc: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var name: String?
    @NSManaged public var openTimesString: String?
    @NSManaged public var photosString: String?
    @NSManaged public var urlString: String?

}

extension FoodVenue : Identifiable {

}
