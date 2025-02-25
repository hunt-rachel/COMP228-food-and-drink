//
//  CoreDataFunctions.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 28/11/2024.
//

import Foundation
import UIKit
import CoreData

class CoreDataFunctions {
    var foodVenues: [FoodVenue] = []
    
    //MARK: Core Data Functions
    //TODO: DUPLICATE VALUES WHEN FETCHING
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        //manages core data stack
        let managedContext = appDelegate.persistentContainer.viewContext
        //what is fetched from core data stack
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodVenue")
        
        //tries to fetch data from core data
        do {
            foodVenues = try managedContext.fetch(fetchRequest) as! [FoodVenue]
            
            print("FETCHED FOOD VENUE\n")
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveData(venueData: FoodData, index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let foodVenue = NSEntityDescription.insertNewObject(forEntityName: "FoodVenue", into: managedContext) as! FoodVenue
        
        //assigning values to associated variables
        foodVenue.name = venueData.food_venues[index].name
        foodVenue.building = venueData.food_venues[index].building
        foodVenue.latitude = venueData.food_venues[index].lat
        foodVenue.longitude = venueData.food_venues[index].lon
        foodVenue.desc = venueData.food_venues[index].description
        foodVenue.openTimesString = venueData.food_venues[index].opening_times.joined(separator: "###")
        foodVenue.amenitiesString = venueData.food_venues[index].amenities?.joined(separator: "###")
        foodVenue.photosString = venueData.food_venues[index].amenities?.joined(separator: "###")
        foodVenue.urlString = venueData.food_venues[index].URL?.absoluteString
        foodVenue.lastModified = venueData.food_venues[index].last_modified
        
        //tries to save values to core data
        do {
            try managedContext.save()
            foodVenues.append(foodVenue)
            print("SAVED FOOD VENUE: \(foodVenue.name!)")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
