//
//  ViewController.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 26/11/2024.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    
    var mapData: FoodData? = nil
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingUser = false
    
    var selectedAnnotationName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getJSONData()
        
        showUserLocation()
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
                    
                    self.mapData = venueInfo
                    
                    DispatchQueue.main.async {
                        self.displayVenue(venueData: self.mapData!) //displays venues on map once their information has been got
                    }
                    
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("You are here!")
        }
    }
    
    //MARK: Display Venues On Map
    func displayVenue(venueData: FoodData) {
        for aVenue in venueData.food_venues {
            let name = aVenue.name
            let lat = aVenue.lat
            let lon = aVenue.lon
            
            guard let latitude = Double(lat) else { return }
            guard let longitude = Double(lon) else { return }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = name
            
            map.addAnnotation(annotation)
            print("added to map: \(aVenue.name)") //for testing/debug purposes
        }
    }
    
    //MARK: Location Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] //returns array of locations, usually only one
        
        //get users coordinates for location
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun {
            firstRun = false
            
            //defines how large area of map is
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            //centre and size of area covered
            let region = MKCoordinateRegion(center: location, span: span)
            
            //show defined region
            self.map.setRegion(region, animated: true)
            
            //prevent bug affecting zoom to user's location
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        
        if startTrackingUser == true {
            map.setCenter(location, animated: true)
        }
    }
    
    @objc func startUserTracking() {
        startTrackingUser = true
    }
    
    func showUserLocation() {
        //makes MapVC delegate of Location Manager
        locationManager.delegate = self as CLLocationManagerDelegate
        
        //set accuracy level of user location
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //ask location manager to request authorisatio from user
        //will only happen once if user selects "while in use" option
        locationManager.requestWhenInUseAuthorization()
        
        //once access authorised, requests updates on user location when moving
        locationManager.startUpdatingLocation()
        
        map.showsUserLocation = true
    }
    
    //MARK: Show Detail on Annotation Tap
    //segue to detail
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotationName = (view.annotation?.title!)! //to compare against map data for passing correct data through segue
        performSegue(withIdentifier: "mapToDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToDetail" {
            let detailsVC = segue.destination as! DetailsVC
            let index = getIndex(annotationName: selectedAnnotationName)
            
            detailsVC.prevVC = "MapVC"
            
            detailsVC.titleString = mapData?.food_venues[index].name ?? "no name"
            detailsVC.buildingString = mapData?.food_venues[index].building ?? "no building"
            detailsVC.descriptionString = mapData?.food_venues[index].description ?? ""
            detailsVC.urlString = mapData?.food_venues[index].URL?.absoluteString
            detailsVC.lastModifiedString = mapData?.food_venues[index].last_modified
            
            detailsVC.openingTimesArr = mapData?.food_venues[index].opening_times
            detailsVC.amenitiesArr = mapData?.food_venues[index].amenities
        }
    }
    
    //gets associated mapData index to allow passing of correct data through segue
    func getIndex(annotationName: String) -> Int {
        var index: Int?
        for venue in 0 ..< (mapData?.food_venues.count)! {
            if annotationName == mapData?.food_venues[venue].name {
                index = venue
                break
            }
            
            else {
                continue
            }
        }
        return index! //as annotation name derived from map data, will always match an index in map data - no default value needed
    }
    
    //unwind segue
    @IBAction func unwindToMap(_ unwindSegue: UIStoryboardSegue) {
        let _ = unwindSegue.source
    }
    
}





