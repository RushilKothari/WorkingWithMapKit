//
//  MapViewModel.swift
//  WorkingWithMapKit
//
//  Created by Rushil Kothari on 20/06/23.
//
//import Foundation
//import CoreLocation
//import MapKit
//
//enum MapDetails {
//    static let startingLocation = CLLocationCoordinate2D(latitude: 13.08784, longitude: 80.27847)
//    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//}
//
//final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
//
//    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
//
//    var locationManager: CLLocationManager?
//
//    func checkLocationServicesEnabled() {
//
//        if CLLocationManager.locationServicesEnabled(){
//            locationManager = CLLocationManager()
//            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager?.delegate = self
//        }
//        else {
//            print("Show them an alert letting them know that location services is disabled")
//        }
//    }
//
//    func checkLocationServicesAuthorization() {
//
//        if CLLocationManager.locationServicesEnabled(){
//            guard let locationManager = locationManager else {return}
//
//            switch locationManager.authorizationStatus {
//
//            case .notDetermined:
//                locationManager.requestWhenInUseAuthorization()
//            case .restricted:
//                print("Your location is restricted likely due to parent controls.")
//            case .denied:
//                print("You have denied this app location permission. Go to setttings to change it")
//            case .authorizedAlways:
//                break
//            case .authorizedWhenInUse:
//                region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            @unknown default:
//                break
//            }
//        }
//    }
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationServicesAuthorization()
//    }
//}
