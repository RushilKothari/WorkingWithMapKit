//
//  MapViewModel.swift
//  WorkingWithMapKit
//
//  Created by Rushil Kothari on 21/06/23.
//

import Foundation
import CoreLocation
import MapKit

//MARK: Using Combine Framework to watch Textfield Change
import Combine

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    //MARK: Search Bar Text
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    //MARK: User Location
    @Published var userLocation: CLLocation?
    @Published var displayLocation: String = ""
    //MARK: Final Location
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    
    override init() {
        super.init()
        //MARK: Setting delegates
        manager.delegate = self
        mapView.delegate = self
        
        //MARK: Requesting Location Access
        manager.requestWhenInUseAuthorization()
        
        //MARK: Search Textfield watching
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { value in
                if value != "" {
                    self.fetchPlaces(value: value)
                }
                else {
                    self.fetchedPlaces = nil
                }
            })
    }
    
    func fetchPlaces(value: String) {
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                // We can also use MainActor to publish changes in Main Thread
                await MainActor.run(body: {
                    self.fetchedPlaces = response.mapItems.compactMap({ item -> CLPlacemark? in
                        return item.placemark
                    })
                })
            }
            catch {
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle Error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        self.userLocation = currentLocation
    }
    
    //MARK: Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted likely due to parent controls.")
        case .denied:
            handleLocationError()
        case .authorizedAlways:
            manager.requestLocation()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func handleLocationError() {
        //Handle Error
        print("You have denied this app location permission. Go to setttings to change it")
    }
    
    //MARK: Add Draggable Pin to MapView
    func addDraggablePin(coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Service will be provided here"
        mapView.addAnnotation(annotation)
//        self.pickedLocation = .init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//        updatePlaceMark(location: .init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), confirmClicked: false)
    }
    
    //MARK: Enabling Dragging
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "SERVICEPIN")
        marker.isDraggable = true
        marker.canShowCallout = false
        return marker
    }
    
    //Updating new location detail
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        print("Updated")
        guard let newLocation = view.annotation?.coordinate else {return}
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlaceMark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude), confirmClicked: true)
    }
    
    func updatePlaceMark(location: CLLocation, confirmClicked: Bool) {
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: location) else {return}
                await MainActor.run(body: {
                    self.pickedPlaceMark = place
                    print("Updated Placemark - ")
                    print(place)
                    if(confirmClicked == true) {
                        print("Confirmed Placemark")
                        print(place)
                        print("\(place.subLocality ?? ""),\(place.locality ?? "")")
                        displayLocation = "\(place.subLocality ?? ""),\(place.locality ?? "")"
                    }
                })
            }
            catch {
                //Handle Error
            }
        }
    }
    
    //MARK: Displaying New Location Data
    func reverseLocationCoordinates(location: CLLocation) async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
}
