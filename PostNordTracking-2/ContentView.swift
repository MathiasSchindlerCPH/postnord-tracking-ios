//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676 | 00370733742650018077

import SwiftUI

struct ContentView: View {
    @State private var selectedLanguageCode = "en"
    @State private var isTrackingViewActive: Bool = false
    
    @State private var manualSearchId: String = ""
    @State private var tappedRecentSearchId: String = ""
    @State private var trackingViewSearchId: String = ""
    
    @State private var recentSearches: [[String: Any]] = UserDefaults.standard.array(forKey: "RecentSearches") as? [[String: Any]] ?? []
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("Enter tracking ID", text: $manualSearchId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !manualSearchId.isEmpty {
                                navigateToTrackingView(search: manualSearchId)
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.bottom)
                    
                    // Recent Searches List
                    if !recentSearches.isEmpty {
                        VStack(alignment: .leading) {
                            Button(role: .destructive, action: {
                                clearRecentSearches()
                            }) {
                                Label("Clear Recent Searches", systemImage: "trash")
                            }
                            .padding()
                        }
                    } else {
                        VStack {
                            Text("Recent searches will appear here")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle("Post Tracking")
                .navigationDestination(isPresented: $isTrackingViewActive) {
                    TrackingView(inputReferenceNumber: trackingViewSearchId, selectedLanguageCode: selectedLanguageCode)
                    .onDisappear {
                        //Only update recent searches after TrackingView closes
                        saveRecentSearch(searchId: manualSearchId)
                        
                        // Reset manualSearchId and trackingViewSearchId after closing trackingView
                        manualSearchId = ""
                        trackingViewSearchId = ""
                    }
                }
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
    
    private func navigateToTrackingView(search: String) {
        if !manualSearchId.isEmpty {
            trackingViewSearchId = manualSearchId
        } else if !tappedRecentSearchId.isEmpty {
            trackingViewSearchId = tappedRecentSearchId
        }
        isTrackingViewActive = true
    }
    
    private func saveRecentSearch(searchId: String) {
        print("Previous recent searches: \(recentSearches)")
        
        let searchedOn = Int(Date().timeIntervalSince1970)
        
        // Check if searchId is already in recentSearches
        let searchExists = recentSearches.contains { $0["parcelId"] as? String == searchId }
        
        if !searchExists {
            let newSearch: [String: Any] = ["parcelId": searchId, "lastSearchedOn": searchedOn]
            recentSearches.append(newSearch)
            UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
            print("Updated recent searches: \(recentSearches)")
        } else {
            print("No new search saved. recentSearches already included last search.")
        }
    }
    
    private func clearRecentSearches() {
        print("Previous recent searches: \(recentSearches)")
        
        if !recentSearches.isEmpty {
            recentSearches.removeAll()
            UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
            print("Recent searches cleared. Current recent searches state variable: \(recentSearches)")
        }
    }
}

/*#Preview {
    ContentView()
}*/
