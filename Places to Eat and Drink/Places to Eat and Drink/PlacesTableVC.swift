//
//  PlacesTableVC.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 26/11/2024.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class PlacesTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var theTable: UITableView!
    
    let userDefaults = UserDefaults.standard
    var opinionArr: [Bool] = []
    
    var tableData: FoodData? = nil
    var nameAndDistance: [(name: String, distance: Double)] = []
    var sortedTableData: [Venue_Info] = []
    var selectedIndex: Int?
    
    var userLocation: CLLocation?

    let mvc = MapVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getJSONData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userLocation = mvc.locationManager.location //gets updated user location each time table view appears, instead of just at initial load
        
        if tableData != nil { //prevents trying to sort table data before fetched from JSON
            sortByDistance(venueData: tableData!, userLoc: userLocation!)
            updateTheTable()
        }
    }

    //MARK: Getting JSON Data
    func getJSONData() {
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/eating_venues/data.json") {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let venueInfo = try decoder.decode(FoodData.self, from: jsonData)
                    
                    self.tableData = venueInfo
                    
                    DispatchQueue.main.async {
                        self.sortByDistance(venueData: self.tableData!, userLoc: self.userLocation!)
                        self.updateTheTable()
                    }
                    
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("You are here!")
            }
    }
    
    func updateTheTable() {
        theTable.reloadData()
    }
    
    //MARK: Sorting Data for Table
    func calculateDistance(userLoc: CLLocation, venueLoc: CLLocation) -> Double {
        return userLoc.distance(from: venueLoc) //returns value for comparison when sorting table by distance
    }
    
    func sortByDistance(venueData: FoodData, userLoc: CLLocation) {
        //clearing array to allow sort from clean slate
        nameAndDistance.removeAll()
        sortedTableData.removeAll()
        
        //for each venue in count, calculate distance between userLoc and venueLoc, append to sorted array with name, sort this new array
        //then alter original table data to fit sorted table data
        for venue in 0 ..<  venueData.food_venues.count {
            guard let venueLat = Double(venueData.food_venues[venue].lat) else {return}
            guard let venueLon = Double(venueData.food_venues[venue].lon) else {return}
            
            let venueLocation = CLLocation(latitude: venueLat, longitude: venueLon)
            let distance = calculateDistance(userLoc: userLoc, venueLoc: venueLocation)
            
            nameAndDistance.append((name: venueData.food_venues[venue].name, distance: distance))
        }
        
        nameAndDistance.sort(by: {$0.distance < $1.distance})
        
        for x in 0 ..< nameAndDistance.count {
            for y in 0 ..< (tableData?.food_venues.count)! {
                if nameAndDistance[x].name == tableData?.food_venues[y].name {
                    appendToSortedArray(venueData: tableData!, index: y) //adds venue data to sorted array in same order as sorted distance array
                }
                
                else {
                    continue
                }
            }
        }
        
        print("sorted table by distance.")
    }
    
    func appendToSortedArray(venueData: FoodData, index: Int) {
        sortedTableData.append(Venue_Info(name: venueData.food_venues[index].name, building: venueData.food_venues[index].building, lat: venueData.food_venues[index].lat, lon: venueData.food_venues[index].lon, description: venueData.food_venues[index].description, opening_times: venueData.food_venues[index].opening_times, amenities: venueData.food_venues[index].amenities, photos: venueData.food_venues[index].photos, URL: venueData.food_venues[index].URL, last_modified: venueData.food_venues[index].last_modified))
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        var content = UIListContentConfiguration.cell()
        
        content.text = sortedTableData[indexPath.row].name
        content.secondaryText = sortedTableData[indexPath.row].building
        
        if userDefaults.object(forKey: sortedTableData[indexPath.row].name) != nil {
            opinionArr = userDefaults.object(forKey: sortedTableData[indexPath.row].name) as! [Bool]
        }
        
        else {
            opinionArr = [false, true, false] //defaults opinion to neutral if no data saved
        }
        
        switch opinionArr {
        case [true, false, false]: //user disliked venue
            content.image = UIImage(systemName: "hand.thumbsdown.fill")
            content.imageProperties.tintColor = UIColor.systemRed
            
        case [false, false, true]: //user liked venue
            content.image = UIImage(systemName: "hand.thumbsup.fill")
            content.imageProperties.tintColor = UIColor.systemGreen
            
        default: //user felt neutral about venue
            content.image = UIImage(systemName: "circle.fill")
            content.imageProperties.tintColor = UIColor.gray
            content.imageProperties.maximumSize = CGSize(width: 8, height: 8)
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "tableToDetail", sender: nil)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToDetail" {
            let detailsVC = segue.destination as! DetailsVC
            detailsVC.prevVC = "PlacesTableVC"
            
            detailsVC.titleString = sortedTableData[selectedIndex!].name
            detailsVC.buildingString = sortedTableData[selectedIndex!].building
            
            detailsVC.openingTimesArr = sortedTableData[selectedIndex!].opening_times
            
            detailsVC.amenitiesArr = sortedTableData[selectedIndex!].amenities ?? ["no amenities"]
            detailsVC.descriptionString = sortedTableData[selectedIndex!].description
            
            detailsVC.urlString = sortedTableData[selectedIndex!].URL?.absoluteString ?? "no url string" //converts url to string for text view
            detailsVC.lastModifiedString = sortedTableData[selectedIndex!].last_modified
        }
    }
    
    @IBAction func unwindToTable(_ unwindSegue: UIStoryboardSegue) {
        let _ = unwindSegue.source
    }
}
