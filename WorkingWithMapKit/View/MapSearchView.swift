//
//  SearchView.swift
//  WorkingWithMapKit
//
//  Created by Rushil Kothari on 21/06/23.
//

import SwiftUI
import MapKit

struct MapSearchView: View {
    @StateObject var mapViewModel: MapViewModel = .init()
    //MARK: Navigation Tag to push view to MapView
    @State var checkConfirmButtonClicked: Bool = false
    @State var navigationTag: String?
    var body: some View {
        NavigationStack{
            VStack {
                HStack(spacing: 15) {
                    
//                    Button {
//
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .foregroundColor(.primary)
//                    }
                    
                    Text("Search Location")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if mapViewModel.displayLocation == ""{
                        Text("Detect Location?")
                            .underline()
                    }
                    else {
                        Text(mapViewModel.displayLocation)
                            .underline()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Choose Location", text: $mapViewModel.searchText)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.gray)
                }
                .padding(.vertical, 10)
                
                if let places = mapViewModel.fetchedPlaces, !places.isEmpty{
                    List{
                        ForEach(places, id: \.self){place in
                            Button {
                                if let coordinates = place.location?.coordinate {
                                    mapViewModel.pickedLocation = .init(latitude: coordinates.latitude, longitude: coordinates.longitude)
                                    mapViewModel.mapView.region = .init(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                    mapViewModel.addDraggablePin(coordinates: coordinates)
                                    mapViewModel.updatePlaceMark(location: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), confirmClicked: checkConfirmButtonClicked)
                                    
                                    //MARK: Navigating to MapView
                                    navigationTag = "MAPVIEW"
                                }
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        
                                        Text(place.name ?? "")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text(place.locality ?? "")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            
                        }
                    }
                    .listStyle(.plain)
                }
                else {
                    //MARK: Live Location Button
                    
                    Button {
                        //MARK: Setting Map Region
                        if let coordinates = mapViewModel.userLocation?.coordinate {
                            mapViewModel.mapView.region = .init(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
                            mapViewModel.addDraggablePin(coordinates: coordinates)
                            mapViewModel.updatePlaceMark(location: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), confirmClicked: checkConfirmButtonClicked)
                        }
                        
                        //MARK: Navigating to MapView
                        navigationTag = "MAPVIEW"
                        
                    } label: {
                        Label {
                            Text("Use Current Location")
                                .font(.callout)
                            //                        .foregroundColor(.black)
                        } icon: {
                            Image(systemName: "location.north.circle.fill")
                            //                        .foregroundColor(.black)
                        }
                        .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background{
                NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                    MapViewSelection()
                        .environmentObject(mapViewModel)
                        .toolbar(.hidden)
                } label: {}
                    .labelsHidden()
            }
        }
    }
}

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchView()
    }
}

//MARK: MapView Live Selection
struct MapViewSelection: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @State var checkConfirmButtonClicked: Bool = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(mapViewModel)
                .ignoresSafeArea()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            //MARK: Displaying Data
            if let place = mapViewModel.pickedPlaceMark{
                VStack(spacing: 15) {
                    Text("Confirm Location")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(place.name ?? "")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        getConfirmedLocation()
                        checkConfirmButtonClicked.toggle()
                    } label: {
                        Text("Confirm Location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.trailing)
                            }
                            .foregroundColor(.white)
                    }
                    
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onDisappear {
            mapViewModel.pickedLocation = nil
            mapViewModel.pickedPlaceMark = nil
            mapViewModel.mapView.removeAnnotations(mapViewModel.mapView.annotations)
        }
    }
    
    func getConfirmedLocation(){
        if let coordinates = mapViewModel.userLocation?.coordinate{
            mapViewModel.addDraggablePin(coordinates: coordinates)
            mapViewModel.updatePlaceMark(location: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), confirmClicked: checkConfirmButtonClicked)
        }
        dismiss()
    }
}

//MARK: UIKit MapView
struct MapViewHelper: UIViewRepresentable {
    
    @EnvironmentObject var mapViewModel: MapViewModel
    
    //    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        return mapViewModel.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}
