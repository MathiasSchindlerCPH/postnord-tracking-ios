//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676

import SwiftUI

struct ContentView: View {
    @State private var selectedLanguageCode = "en"
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    @State private var inputReferenceNumber: String = ""
    
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
                    .padding(.bottom)
                    
                    // Recent Searches List
                    VStack(alignment: .leading) {
                        Text("Recent Searches")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ScrollView {
                            ForEach(recentSearches, id: \.self) { search in
                                NavigationLink(destination: TrackingView(inputReferenceNumber: search, selectedLanguageCode: selectedLanguageCode)) {
                                    VStack(alignment: .leading) {
                                        Text(search)
                                            .padding(.vertical, 8)
                                        Divider()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Button to clear recent searches
                            Button(action: {
                                clearRecentSearches()
                            }) {
                                Text("Clear Recent Searches")
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .buttonStyle(BorderedButtonStyle())
                        }
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
        .onChange(of: inputReferenceNumber) {
            // Add the new search to recent searches list
            updateRecentSearches(inputReferenceNumber)
            saveRecentSearches()
        }
    }
    
    private func updateRecentSearches(_ newSearch: String) {
        // Ensure no duplicates are added
        if recentSearches.contains(newSearch) {
            // Move existing search to the top
            if let index = recentSearches.firstIndex(of: newSearch) {
                recentSearches.remove(at: index)
                recentSearches.insert(newSearch, at: 0)
            }
        } else {
            // Add new search at the top
            recentSearches.insert(newSearch, at: 0)
        }
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
}

struct TrackingView: View {
    let inputReferenceNumber: String
    let selectedLanguageCode: String
    
    @State private var isLoading = true
    @State private var shipmentEvents: [ShipmentEvent] = []
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if !shipmentEvents.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Shipment details for \(inputReferenceNumber)")
                            .font(.headline)
                            .padding(.bottom, 8)
                        Divider()
                        
                        ForEach(shipmentEvents) { event in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.eventTime)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("\(event.locationName), \(event.locationCountry)")
                                    .font(.subheadline)
                                
                                Text(event.eventDescription)
                                    .font(.body)
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding()
                }
            } else {
                Text("No shipment data found.")
                    .foregroundColor(.gray)
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
                        self.shipmentEvents = events
                        self.isLoading = false
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.shipmentEvents = []
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
