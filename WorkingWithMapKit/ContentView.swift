//
//  ContentView.swift
//  WorkingWithMapKit
//
//  Created by Rushil Kothari on 19/06/23.
//
//
//import SwiftUI
//import MapKit
//
//struct ContentView: View {
//    @StateObject private var mapViewModel = ContentViewModel()
//    
//    var body: some View {
//        Map(coordinateRegion: $mapViewModel.region, showsUserLocation: true)
//            .ignoresSafeArea()
//            .tint(.pink)
//            .onAppear {
//                mapViewModel.checkLocationServicesEnabled()
//                
//            }
//    }
//    
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView()
//        }
//    }
//}
