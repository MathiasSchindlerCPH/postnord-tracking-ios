//
//  ContentView.swift
//  PostNordTracking
//
//  Created by Mathias Schindler on 27/06/2024.
//

// Test tracking-ID: 00370730254738217676 | 00370733742650018077

import SwiftUI

struct ContentView: View {
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    
    @State private var selectedLanguageCode = "en"
    @State private var isTrackingViewActive: Bool = false
    
    @State private var manualSearchId: String = ""
    @State private var tappedRecentSearchId: String = ""
    @State private var trackingViewSearchId: String = ""
    
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
                            Text("Recent Searches")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ScrollView {
                                ForEach(recentSearches, id: \.self) { search in
                                    Button(action: {
                                        tappedRecentSearchId = search
                                        navigateToTrackingView(search: tappedRecentSearchId)
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(search)
                                                .padding(.vertical, 8)
                                            Divider()
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Button to clear recent searches
                                Button(role: .destructive, action: {
                                    clearRecentSearches()
                                }) {
                                    Label("Clear Recent Searches", systemImage: "trash")
                                }
                                .padding()
                            }
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
                        updateRecentSearches(trackingViewSearchId)
                        
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
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches() // This call also clears recentSeaches from UserDefaults (bc of saveRecentSearches logic)
    }
}

/*#Preview {
    ContentView()
}*/
