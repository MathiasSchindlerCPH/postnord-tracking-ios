//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var inputReferenceNumber: String = ""
    @State private var selectedLanguageCode = "en"
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    HStack {
                        TextField("Enter tracking ID", text: $inputReferenceNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        NavigationLink(destination: TrackingView(inputReferenceNumber: inputReferenceNumber, selectedLanguageCode: selectedLanguageCode)) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle("Post Tracking")
                .padding()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                LanguageSelectionView(selectedLanguageCode: $selectedLanguageCode)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct TrackingView: View {
    let inputReferenceNumber: String
    let selectedLanguageCode: String
    
    @State private var isLoading = true
    @State private var shipmentDetails: String = ""
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    Text("Shipment details for \(inputReferenceNumber)")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Text(shipmentDetails)
                        .font(.system(.body))
                }
                .padding()
            }
        }
        .navigationTitle("Tracking Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            APIManager.fetchShipmentDetails(for: inputReferenceNumber, locale: selectedLanguageCode) { result in
                switch result {
                case .success(let events):
                    DispatchQueue.main.async {
                        var details = ""
                        for event in events {
                            let eventTime = event.eventTime ?? "N/A"
                            let eventDescription = event.eventDescription ?? "N/A"
                            details += "\(eventTime)\n\(eventDescription)\n\n"
                        }
                        self.shipmentDetails = details
                        self.isLoading = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.shipmentDetails = "Failed to fetch shipment details: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var selectedLanguageCode: String

    let languages = ["English": "en", "Danish": "da"]

    var body: some View {
        VStack {
            Text("Select Language")
            Picker(selection: $selectedLanguageCode, label: Text("Select Language")) {
                ForEach(languages.sorted(by: <), id: \.value) { name, code in
                    Text(name).tag(code)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
        }
        .navigationTitle("Language Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*#Preview {
    ContentView()
}*/
