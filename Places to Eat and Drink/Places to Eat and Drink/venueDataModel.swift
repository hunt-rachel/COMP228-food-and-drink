//
//  venueDataModel.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 27/11/2024.
//

import Foundation

struct FoodData: Codable {
    var food_venues: [Venue_Info]
    let last_modified: String
}

struct Venue_Info: Codable {
    let name: String
    let building: String
    let lat: String
    let lon: String
    let description: String
    let opening_times: [String]
    let amenities: [String]?
    let photos: [String]?
    let URL: URL?
    let last_modified: String
}
