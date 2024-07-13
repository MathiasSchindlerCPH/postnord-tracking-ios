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
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    @State private var inputReferenceNumber: String = ""
    @State private var isTrackingViewActive: Bool = false
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("Enter tracking ID", text: $inputReferenceNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            if !inputReferenceNumber.isEmpty {
                                updateRecentSearches(inputReferenceNumber)
                                saveRecentSearches()
                                isTrackingViewActive = true
                            }
                        }) {
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
                            if !recentSearches.isEmpty {
                                Button(role: .destructive, action: {
                                        clearRecentSearches()
                                    }) {
                                        Label("Clear Recent Searches", systemImage: "trash")
                                }
                                .padding()
                            } else {
                                
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationTitle("Post Tracking")
                .navigationDestination(isPresented: $isTrackingViewActive) {
                    TrackingView(inputReferenceNumber: inputReferenceNumber, selectedLanguageCode: selectedLanguageCode)
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

/*#Preview {
    ContentView()
}*/
